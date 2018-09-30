#include <stdio.h>

#include <kernel/tty.h>

void kernel_main(void) {
    terminal_initialize();
    printf("                                                                 \n");
    printf("                                                                 \n");
    printf("                                                                 \n");
    printf("                                                                 \n");
    printf("                                                                 \n");
    terminal_setcolor(5);
    printf("               ##      ##  ##    ##    ####    ########    ####  \n");
    printf("               ##      ##  ##    ##   ##  ##      ##      ##  ## \n");
    printf("               ##      ##  ##    ##  ##    ##     ##     ##    ##\n");
    printf("               ###    ###  ##    ##  ##    ##     ##     ##    ##\n");
    terminal_setcolor(7);
    printf("               ###    ###  ##    ##  ##           ##     ##    ##\n");
    printf("               ###    ###  ##    ##  ####         ##     ##    ##\n");
    printf("               ##########   ##  ##    ####        ##     ##    ##\n");
    terminal_setcolor(9);
    printf("               ##  ##  ##    ####       ####      ##     ##    ##\n");
    printf("               ##  ##  ##     ##         ####     ##     ########\n");
    printf("               ##  ##  ##     ##           ##     ##     ##    ##\n");
    terminal_setcolor(11);
    printf("               ##      ##     ##     ##    ##     ##     ##    ##\n");
    printf("               ##      ##     ##     ##    ##     ##     ##    ##\n");
    printf("               ##      ##     ##      ##  ##      ##     ##    ##\n");
    printf("               ##      ##     ##       ####    ########  ##    ##\n");
}
