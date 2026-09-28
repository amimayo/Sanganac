#define TEST_DATA_ADDR 0x00000300

int main(void) {

    volatile unsigned int *ram = (volatile unsigned int*)TEST_DATA_ADDR;

    unsigned int a = 0x10;
    unsigned int b = 0x60;

    unsigned int result = a + b;

    *ram = result;

    asm volatile("ebreak");

    while(1) {
        asm volatile("nop");
    }

    return 0;

}