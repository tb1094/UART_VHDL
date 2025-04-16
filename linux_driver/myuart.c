/*  myuart.c - The simplest kernel module.

* Copyright (C) 2013 - 2016 Xilinx, Inc
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation; either version 2 of the License, or
*   (at your option) any later version.

*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License along
*   with this program. If not, see <http://www.gnu.org/licenses/>.

*/

/* myUART register map
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

#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>

/* Standard module information, edit as appropriate */
MODULE_LICENSE("GPL");
MODULE_AUTHOR
    ("tb1094");
MODULE_DESCRIPTION
    ("myuart - driver for custom uart ip");


#define DRIVER_NAME "myuart"
#define DRIVER_VERSION "v0.5.1"
MODULE_INFO(version, DRIVER_VERSION);

// 32 bit slave registers
#define REG_LEN 4

struct myuart_local {
	int irq;
	unsigned long mem_start;
	unsigned long mem_end;
	void __iomem *base_addr;
};

static struct myuart_local* myuart_info = NULL;

void myuart_snd(void) {
	// hard code data for testing
	u8 bytedata = 'x';
	u32 sreg3_data;

	if (myuart_info == NULL) {
		printk("myuart_info is NULL!\n");
		return;
	}

	// write data to tx data register
	iowrite32((u32) bytedata, myuart_info->base_addr + REG_LEN*1);
	printk("wrote data to tx data register\n");
	// set WR_UART bit to 1
	sreg3_data = ioread32(myuart_info->base_addr + REG_LEN*3);
	iowrite32(sreg3_data | (1 << 1), myuart_info->base_addr + REG_LEN*3);
	printk("set WR_UART bit to 1\n");
}

// print slave regs for debugging
void myuart_print_regs(void) {
	unsigned int sreg0_data, sreg1_data, sreg2_data, sreg3_data;

	if (myuart_info == NULL) {
		printk("myuart_info is NULL!\n");
		return;
	}

	sreg0_data = ioread32(myuart_info->base_addr + REG_LEN*0);
	sreg1_data = ioread32(myuart_info->base_addr + REG_LEN*1);
	sreg2_data = ioread32(myuart_info->base_addr + REG_LEN*2);
	sreg3_data = ioread32(myuart_info->base_addr + REG_LEN*3);

	printk("SLV_REG0: 0x%08x\n", sreg0_data);
	printk("SLV_REG1: 0x%08x\n", sreg1_data);
	printk("SLV_REG2: 0x%08x\n", sreg2_data);
	printk("SLV_REG3: 0x%08x\n", sreg3_data);
}

/* Simple example of how to receive command line parameters to your module.
   Delete if you don't need them */
unsigned myint = 0xdeadbeef;
char *mystr = "default";

module_param(myint, uint, S_IRUGO);
module_param(mystr, charp, S_IRUGO);

static irqreturn_t myuart_irq(int irq, void *dev_id)
{
	unsigned int status, sreg3_data;

	printk("myuart interrupt\n");

	if (myuart_info == NULL) {
		printk("myuart_info is NULL!\n");
		return IRQ_HANDLED;
	}

	status = ioread32(myuart_info->base_addr + REG_LEN*2);
	printk("STATUS REGISTER: 0x%08x\n", status);

	// set intr_ack bit to 1
	sreg3_data = ioread32(myuart_info->base_addr + REG_LEN*3);
	iowrite32(sreg3_data | (1 << 2), myuart_info->base_addr + REG_LEN*3);
	return IRQ_HANDLED;
}

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
	lp = (struct myuart_local *) kmalloc(sizeof(struct myuart_local), GFP_KERNEL);
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

	myuart_info = lp;

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

static int __init myuart_init(void)
{
	int retval;
	printk("<1>Hello module world.\n");
	//printk("<1>Module parameters were (0x%08x) and \"%s\"\n", myint, mystr);

	retval = platform_driver_register(&myuart_driver);

	if (retval) {
		printk(KERN_ERR "Failed to register platform driver: %d\n", retval);
		return retval;
	}

	myuart_print_regs();

	// test interrupts
	myuart_snd();

	return retval;
}


static void __exit myuart_exit(void)
{
	platform_driver_unregister(&myuart_driver);
	printk(KERN_ALERT "Goodbye module world.\n");
}

module_init(myuart_init);
module_exit(myuart_exit);
