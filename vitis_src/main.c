#include "xuartps.h"
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "myUARTip.h"
#include "sleep.h"
#include "xscugic.h"
#include "fifo_buf.h"
#include "string.h"

#define BUFSIZE 256
#define MAXLEN 50

/*
 * SLV_REG0[7:0] = RX DATA
 * SLV_REG1[7:0] = TX DATA
 * SLV_REG2[0] = RX_EMPTY
 * SLV_REG2[1] = TX_FULL
 * SLV_REG2[2] = intr_status
 * SLV_REG3[0] = RD_UART
 * SLV_REG3[1] = WR_UART
 * SLV_REG3[2] = intr_ack
*/

// void MYUARTIP_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
// u32 MYUARTIP_mReadReg(u32 BaseAddress, unsigned RegOffset)
// XPAR_FABRIC_MYUART_IRQ_INTR

// instance of interrupt controller
static XScuGic intc;

// instances of buffers for myuart
static FIFO_BUF myuart_rd_buf;
static FIFO_BUF myuart_wr_buf;

static int ECHO = 0;

// isr function prototype
void myUART_ISR(void *intc_inst_ptr);

void myuart_snd() {
	uint8_t bytedata;
	int retval = fifo_buf_read(&myuart_wr_buf, &bytedata);
	if (retval) {
		// buffer is empty
		return;
	}
	// write data to tx data register
	MYUARTIP_mWriteReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG1_OFFSET, (uint32_t) bytedata);
	// set WR_UART bit to 1
	uint32_t sreg3_data = MYUARTIP_mReadReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG3_OFFSET);
	MYUARTIP_mWriteReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG3_OFFSET, sreg3_data | (1 << 1));
}

int myuart_rcv() {
	// read data from rx data register
	uint32_t sreg0_data = MYUARTIP_mReadReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG0_OFFSET);
	// set RD_UART bit to 1
	uint32_t sreg3_data = MYUARTIP_mReadReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG3_OFFSET);
	MYUARTIP_mWriteReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG3_OFFSET, sreg3_data | (1 << 0));
	if (ECHO) {
		// write data to tx data register
		MYUARTIP_mWriteReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG1_OFFSET, (uint32_t) sreg0_data);
		// set WR_UART bit to 1
		uint32_t sreg3_data = MYUARTIP_mReadReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG3_OFFSET);
		MYUARTIP_mWriteReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG3_OFFSET, sreg3_data | (1 << 1));
	} else {
		xil_printf("%c", (uint8_t) sreg0_data);
	}
	return 0;
}

void myuart_print_regs(void) {
	// print slave regs for debugging
	uint32_t sreg0_data = MYUARTIP_mReadReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG0_OFFSET);
	uint32_t sreg1_data = MYUARTIP_mReadReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG1_OFFSET);
	uint32_t sreg2_data = MYUARTIP_mReadReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG2_OFFSET);
	uint32_t sreg3_data = MYUARTIP_mReadReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG3_OFFSET);

	xil_printf("SLV_REG0: 0x%x\r\n", sreg0_data);
	xil_printf("SLV_REG1: 0x%x\r\n", sreg1_data);
	xil_printf("SLV_REG2: 0x%x\r\n", sreg2_data);
	xil_printf("SLV_REG3: 0x%x\r\n", sreg3_data);
}

void myuart_intr_ack(void) {
	// set intr_ack bit to 1
	uint32_t sreg3_data = MYUARTIP_mReadReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG3_OFFSET);
	MYUARTIP_mWriteReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG3_OFFSET, sreg3_data | (1 << 2));
}

// sets up the interrupt system and enables interrupts from myUART
int setup_interrupt_system() {

    int result;
    XScuGic *intc_instance_ptr = &intc;
    XScuGic_Config *intc_config;

    // get config for interrupt controller
    intc_config = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
    if (NULL == intc_config) {
        return XST_FAILURE;
    }

    // initialize the interrupt controller driver
    result = XScuGic_CfgInitialize(intc_instance_ptr, intc_config, intc_config->CpuBaseAddress);

    if (result != XST_SUCCESS) {
        return result;
    }

    // set the priority to 0xC8 and trigger to active HIGH level sensitive
    XScuGic_SetPriorityTriggerType(intc_instance_ptr, XPAR_FABRIC_MYUART_IRQ_INTR, 0xC8, 0x1);

    // connect the myUART interrupt service routine to the interrupt controller
    result = XScuGic_Connect(intc_instance_ptr, XPAR_FABRIC_MYUART_IRQ_INTR, (Xil_ExceptionHandler)myUART_ISR, (void *)&intc);

    if (result != XST_SUCCESS) {
        return result;
    }

    // enable interrupts
    XScuGic_Enable(intc_instance_ptr, XPAR_FABRIC_MYUART_IRQ_INTR);

    // initialize the exception table and register the interrupt controller handler with the exception table
    Xil_ExceptionInit();

    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, intc_instance_ptr);

    // enable non-critical exceptions
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}

char uart_getchar() {
	return XUartPs_RecvByte(STDIN_BASEADDRESS);
}

void uart_gets(char* buf, int maxlen) {
	int i = 0;
	char c;
	while (i < maxlen - 1) {
		c = uart_getchar();
		if (c == '\r' || c == '\n') {
			break;
		}
		buf[i] = c;
		i++;
		//xil_printf("%c", c);  // echo
	}
	buf[i] = '\0';
	xil_printf("\r\n");
}

int main(void) {

	int retval = 0;

	init_platform();

	sleep(1);
	xil_printf("START\r\n");

	// uart buffer initialization
	if (fifo_buf_init(&myuart_rd_buf, BUFSIZE)) {
		xil_printf("uart_rd_buf init failed\r\n");
	}
	if (fifo_buf_init(&myuart_wr_buf, BUFSIZE)) {
		xil_printf("uart_wr_buf init failed\r\n");
	}

	// setup and enable interrupts
	int status = setup_interrupt_system();
	if (status != XST_SUCCESS) {
		xil_printf("interrupt setup failed\r\n");
		return XST_FAILURE;
	}

	char input_string[MAXLEN];
	memset(input_string, 0, MAXLEN);

	while (strcmp(input_string, "q")) {
		// turn on echo
		if (strcmp(input_string, "echo 1") == 0) {
			ECHO = 1;
			memset(input_string, 0, MAXLEN);
		// turn off echo
		} else if (strcmp(input_string, "echo 0") == 0) {
			ECHO = 0;
			memset(input_string, 0, MAXLEN);
		}
		// write the input string to myuart_wr_buf
		for (int i = 0; i < strlen(input_string); i++) {
			retval = fifo_buf_write(&myuart_wr_buf, input_string[i]);
			if (retval) {
				xil_printf("myuart_wr_buf is full\r\n");
				break;
			}
			// if we are on the last loop iteration
			if (i + 1 == strlen(input_string)) {
				// add newline to myuart_wr_buf
				retval = fifo_buf_write(&myuart_wr_buf, '\r');
				if (retval) {
					xil_printf("myuart_wr_buf is full\r\n");
					break;
				}
				retval = fifo_buf_write(&myuart_wr_buf, '\n');
				if (retval) {
					xil_printf("myuart_wr_buf is full\r\n");
					break;
				}
			}
		}
		// manually trigger send to kickstart the process
		XScuGic_Disable(&intc, XPAR_FABRIC_MYUART_IRQ_INTR);
		myuart_snd();
		XScuGic_Enable(&intc, XPAR_FABRIC_MYUART_IRQ_INTR);

		uart_gets(input_string, MAXLEN);
	}

	xil_printf("\r\n");

	// disable interrupts
	XScuGic_Disable(&intc, XPAR_FABRIC_MYUART_IRQ_INTR);
	xil_printf("interrupts disabled\r\n");

	sleep(1);

	fifo_buf_cleanup(&myuart_rd_buf);
	fifo_buf_cleanup(&myuart_wr_buf);

	xil_printf("END\r\n");

	cleanup_platform();

	return 0;
}

void myUART_ISR(void *intc_inst_ptr) {
	//xil_printf("interrupt received!\r\n");
	uint32_t sreg2_data = MYUARTIP_mReadReg(XPAR_MYUART_S_AXI_BASEADDR, MYUARTIP_S_AXI_SLV_REG2_OFFSET);
	if ((sreg2_data & (1 << 0)) == 0) {
		// rx is full - there is new data to read
		// xil_printf("intr: rx is full!\r\n");
		myuart_rcv();
	}
	if ((sreg2_data & (1 << 1)) == 0) {
		// tx is empty - we can send more data
		// xil_printf("intr: tx is empty!\r\n");
		myuart_snd();
	}
    // acknowledge interrupt and set intr status to 0
    myuart_intr_ack();
}

