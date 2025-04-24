/*
 * myUART register map
 * SLV_REG0[7:0] = RX DATA
 * SLV_REG1[7:0] = TX DATA
 * SLV_REG2[0] = RX_EMPTY
 * SLV_REG2[1] = TX_FULL
 * SLV_REG2[2] = intr_status
 * SLV_REG3[0] = RD_UART
 * SLV_REG3[1] = WR_UART
 * SLV_REG3[2] = intr_ack
*/

#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/io.h>
#include <linux/interrupt.h>
#include <linux/types.h>
#include <linux/kfifo.h>
#include <linux/semaphore.h>
#include <linux/uaccess.h>
#include <linux/miscdevice.h>

#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("tb1094");
MODULE_DESCRIPTION("myuart - driver for custom uart ip");

#define DRIVER_NAME "myuart"
#define DRIVER_VERSION "v0.6.0"
MODULE_INFO(version, DRIVER_VERSION);

// 32 bit slave registers so offset is 4
#define REG_LEN 4
// size of fifo buffers
#define FIFO_SIZE 512
#define DBG_SIZE 512

static DECLARE_KFIFO(debug_log, char, DBG_SIZE); // debug fifo

struct myuart_local {
	int irq;
	unsigned long mem_start;
	unsigned long mem_end;
	void __iomem *base_addr;
	struct semaphore semaphore; // semaphore for ensuring only one process is accessing at a time
	DECLARE_KFIFO(fifo_rx, u8, FIFO_SIZE); // macro for struct kfifo
	DECLARE_KFIFO(fifo_tx, u8, FIFO_SIZE); // macro for struct kfifo
	spinlock_t slock; // spinlock for myuart_snd
	wait_queue_head_t read_queue; // for blocking read() call
	struct miscdevice miscdev; // misc device for registering as character device
};


/*******************************************************
 *************** myUART helper functions ***************
 ******************************************************/

// send byte from kfifo buffer
void myuart_snd(struct myuart_local *lp) {
	u32 sreg3_data;
	u8 bytedata;
	size_t n = kfifo_len(&lp->fifo_tx);

	// check if buffer is empty
	if (n == 0) {
		return;
	}

	// load value from buffer
	kfifo_out(&lp->fifo_tx, &bytedata, 1);
	//printk(KERN_INFO "s: 0x%02x\n", bytedata);

	// write data to myuart tx data register
	iowrite32((u32) bytedata, lp->base_addr + REG_LEN*1);

	// set WR_UART bit to 1
	sreg3_data = ioread32(lp->base_addr + REG_LEN*3);
	iowrite32(sreg3_data | (1 << 1), lp->base_addr + REG_LEN*3);
}

// receive byte into kfifo buffer
void myuart_rcv(struct myuart_local *lp) {
	u32 sreg0_data, sreg3_data;

	// check if rx buffer is full
	if (kfifo_is_full(&lp->fifo_rx)) {
		return;
	}

	// read data from myuart rx data register
	sreg0_data = ioread32(lp->base_addr + REG_LEN*0);
	//printk(KERN_INFO "r: 0x%02x\n", sreg0_data & 0xFF);

	// load value into buffer
	kfifo_in(&lp->fifo_rx, (u8*)&sreg0_data, 1);

	// set RD_UART bit to 1
	sreg3_data = ioread32(lp->base_addr + REG_LEN*3);
	iowrite32(sreg3_data | (1 << 0), lp->base_addr + REG_LEN*3);
}

// print slave regs for debugging
void myuart_print_regs(struct myuart_local *lp) {
	unsigned int sreg0_data, sreg1_data, sreg2_data, sreg3_data;

	sreg0_data = ioread32(lp->base_addr + REG_LEN*0);
	sreg1_data = ioread32(lp->base_addr + REG_LEN*1);
	sreg2_data = ioread32(lp->base_addr + REG_LEN*2);
	sreg3_data = ioread32(lp->base_addr + REG_LEN*3);

	printk("R0: 0x%08x\nR1: 0x%08x\nR2: 0x%08x\nR3: 0x%08x\n",
				 sreg0_data, sreg1_data, sreg2_data, sreg3_data);
}


/*******************************************************
 ************* myUART chardevice functions *************
 ******************************************************/


static int myuart_open(struct inode *inode, struct file *file)
{
	struct miscdevice *mdev = file->private_data;
	struct myuart_local *lp = container_of(mdev, struct myuart_local, miscdev);
	printk(KERN_INFO "myuart_open(%p)\n", file);

	if (down_trylock(&lp->semaphore)) {
		return -EBUSY;
	}

	kfifo_reset(&lp->fifo_rx);
	kfifo_reset(&lp->fifo_tx);

	// debugging
	//kfifo_reset(&debug_log);

	file->private_data = lp;

	try_module_get(THIS_MODULE);
	return 0;
}

static int myuart_release(struct inode *inode, struct file *file)
{
	/*
	char out[DBG_SIZE];
	int len;
	*/
	struct myuart_local *lp = file->private_data;
	printk(KERN_INFO "myuart_release(%p,%p)\n", inode, file);

	up(&lp->semaphore);

	/* print debug info
	while (!kfifo_is_empty(&debug_log)) {
		len = kfifo_out(&debug_log, out, sizeof(out) - 1);
		out[len] = '\0';
		printk(KERN_INFO "%s", out);
	}
	*/

	module_put(THIS_MODULE);
	return 0;
}

static ssize_t myuart_read(struct file *file, char __user * buffer, size_t length, loff_t * offset)
{
	struct myuart_local *lp = file->private_data;
	u8 read_data[FIFO_SIZE];
	ssize_t ret;
	size_t to_read;

	// no data in RX buffer?
	if (kfifo_is_empty(&lp->fifo_rx)) {
		// return -EAGAIN if the file is in non-blocking mode
		if (file->f_flags & O_NONBLOCK) {
			return -EAGAIN;
		}
		// block until there's data
		wait_event_interruptible(lp->read_queue, !kfifo_is_empty(&lp->fifo_rx));
	}

	// limit read size to what's actually available
	to_read = min(length, kfifo_len(&lp->fifo_rx));
	kfifo_out(&lp->fifo_rx, read_data, to_read);

	// copy to userspace
	ret = copy_to_user(buffer, read_data, to_read);
	if (ret) {
		return -EFAULT;
	}
	return to_read;
}

static ssize_t myuart_write(struct file *file, const char __user * buffer, size_t length, loff_t * offset)
{
	struct myuart_local *lp = file->private_data;
	u32 sreg2_data;
	unsigned long flags;
	u8 write_data[FIFO_SIZE];
	ssize_t ret;
	size_t available = kfifo_avail(&lp->fifo_tx);
	printk("write: fifo_tx available: %d\n", available);
	if (length <= available && available > 0) {
		ret = copy_from_user(write_data, buffer, length);
		if (ret) {
			return -EFAULT;
		}
		kfifo_in(&lp->fifo_tx, write_data, length);

		// lock and disable interrupts because this code sequence is executed in ISR too
		spin_lock_irqsave(&lp->slock, flags);
		// check if we should kickstart the sending
		sreg2_data = ioread32(lp->base_addr + REG_LEN*2);
		if ((sreg2_data & (1 << 1)) == 0) {
			// tx is empty - we can send more data
			myuart_snd(lp);
		}
		spin_unlock_irqrestore(&lp->slock, flags);

		return length;
	}
	printk("write: fifo_tx available too small\n");
	return 0;
}

struct file_operations Fops = {
	.owner = THIS_MODULE,
	.read = myuart_read,
	.write = myuart_write,
	.open = myuart_open,
	.release = myuart_release,
};


/*******************************************************
 ***************** myUART ISR function *****************
 ******************************************************/


static irqreturn_t myuart_irq(int irq, void *dev_id)
{
	u32 sreg3_data, sreg2_data;
	struct myuart_local *lp;

	lp = (struct myuart_local*) dev_id;
	//myuart_print_regs(lp);

	sreg2_data = ioread32(lp->base_addr + REG_LEN*2);
	if ((sreg2_data & (1 << 0)) == 0) {
		// rx is full - there is new data to read
		myuart_rcv(lp);
		// wake up blocking read call because there is new data
		wake_up_interruptible(&lp->read_queue);
	}
	if ((sreg2_data & (1 << 1)) == 0) {
		// tx is empty - we can send more data
		myuart_snd(lp);
	}

	// set intr_ack bit to 1
	sreg3_data = ioread32(lp->base_addr + REG_LEN*3);
	iowrite32(sreg3_data | (1 << 2), lp->base_addr + REG_LEN*3);

	return IRQ_HANDLED;
}


/*******************************************************
 ********** myUART platform driver functions ***********
 ******************************************************/


static int myuart_probe(struct platform_device *pdev)
{
	struct resource *r_irq; /* Interrupt resources */
	struct resource *r_mem; /* IO mem resources */
	struct device *dev = &pdev->dev;
	struct myuart_local *lp = NULL;

	int rc = 0;
	dev_info(dev, "Device Tree Probing\n");
	/* Get iospace for the device */
	r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!r_mem) {
		dev_err(dev, "invalid address\n");
		return -ENODEV;
	}
	lp = (struct myuart_local *) kzalloc(sizeof(struct myuart_local), GFP_KERNEL);
	if (!lp) {
		dev_err(dev, "Cound not allocate myuart device\n");
		return -ENOMEM;
	}
	dev_set_drvdata(dev, lp);
	lp->mem_start = r_mem->start;
	lp->mem_end = r_mem->end;

	if (!request_mem_region(lp->mem_start,
				lp->mem_end - lp->mem_start + 1,
				DRIVER_NAME)) {
		dev_err(dev, "Couldn't lock memory region at %p\n",
			(void *)lp->mem_start);
		rc = -EBUSY;
		goto error1;
	}

	lp->base_addr = ioremap(lp->mem_start, lp->mem_end - lp->mem_start + 1);
	if (!lp->base_addr) {
		dev_err(dev, "myuart: Could not allocate iomem\n");
		rc = -EIO;
		goto error2;
	}

	/* Get IRQ for the device */
	r_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
	if (!r_irq) {
		dev_info(dev, "no IRQ found\n");
		dev_info(dev, "myuart at 0x%08x mapped to 0x%08x\n",
			(unsigned int __force)lp->mem_start,
			(unsigned int __force)lp->base_addr);
		return 0;
	}
	lp->irq = r_irq->start;

	// initialize semaphore
	sema_init(&lp->semaphore, 1);

	// initialize fifo buffers
	INIT_KFIFO(lp->fifo_rx);
	INIT_KFIFO(lp->fifo_tx);

	//initialize spinlock
	spin_lock_init(&lp->slock);

	// initialize read queue
	init_waitqueue_head(&lp->read_queue);

	// set up misc device
	lp->miscdev.minor = MISC_DYNAMIC_MINOR;
	lp->miscdev.name = "myuart";
	lp->miscdev.fops = &Fops;
	lp->miscdev.parent = dev;
	lp->miscdev.mode = 0666;

	rc = misc_register(&lp->miscdev);

	if (rc) {
		printk("misc_register failed\n");
	}

	rc = request_irq(lp->irq, &myuart_irq, 0, DRIVER_NAME, lp);
	if (rc) {
		dev_err(dev, "testmodule: Could not allocate interrupt %d.\n",
			lp->irq);
		goto error3;
	}

	dev_info(dev,"myuart at 0x%08x mapped to 0x%08x, irq=%d\n",
		(unsigned int __force)lp->mem_start,
		(unsigned int __force)lp->base_addr,
		lp->irq);
	return 0;
error3:
	free_irq(lp->irq, lp);
error2:
	release_mem_region(lp->mem_start, lp->mem_end - lp->mem_start + 1);
error1:
	kfree(lp);
	dev_set_drvdata(dev, NULL);
	return rc;
}

static int myuart_remove(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct myuart_local *lp = dev_get_drvdata(dev);
	free_irq(lp->irq, lp);
	iounmap(lp->base_addr);
	release_mem_region(lp->mem_start, lp->mem_end - lp->mem_start + 1);

	misc_deregister(&lp->miscdev);

	kfree(lp);
	dev_set_drvdata(dev, NULL);
	return 0;
}

#ifdef CONFIG_OF
static struct of_device_id myuart_of_match[] = {
	{ .compatible = "xlnx,myUARTip-1.0", },
	{ /* end of list */ },
};
MODULE_DEVICE_TABLE(of, myuart_of_match);
#else
# define myuart_of_match
#endif


static struct platform_driver myuart_driver = {
	.driver = {
		.name = DRIVER_NAME,
		.owner = THIS_MODULE,
		.of_match_table	= myuart_of_match,
	},
	.probe		= myuart_probe,
	.remove		= myuart_remove,
};


/******************************************************
 ************* myUART init/exit functions *************
 *****************************************************/


static int __init myuart_init(void)
{
	int retval;
	printk("Hello module world.\n");
	//printk("Module parameters were (0x%08x) and \"%s\"\n", myint, mystr);

	retval = platform_driver_register(&myuart_driver);

	if (retval) {
		printk(KERN_ERR "Failed to register platform driver: %d\n", retval);
		return retval;
	}

	// debugging
	//INIT_KFIFO(debug_log);

	return retval;
}


static void __exit myuart_exit(void)
{
	platform_driver_unregister(&myuart_driver);
	printk(KERN_ALERT "Goodbye module world.\n");
}

module_init(myuart_init);
module_exit(myuart_exit);
