#include <stdio.h>

#include <kernel/tty.h>
#include <kernel/kernel.h>

/*
 ___     ___   __    __   ______   ______    _____
|   |   |   | |  |  |  | |      | |_    _|  /     \
|    \_/    | |   \/   | |  ___/    |  |   |   _   |
|           |  \      /   \___ \    |  |   |  |_|  |
|   |\_/|   |   \    /    /     |   |  |   |   _   |
|   |   |   |    |  |    |      |  _|  |_  |  | |  |
|___|   |___|    |__|    |_____/  |______| |__| |__|
*/

void kernel_main(void) {
    terminal_initialize();

    show_logo();

    printf("\n\n\n\n\n\n\n\n");
    printf("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");
}

void show_logo(void) {
    terminal_clear();
    printf("\n\n\n\n\n\n\n\n");
    terminal_setcolor(10); // 10 = lightgreen
    printf("              ___     ___   __    __   ______   ______    _____  \n");
    printf("             |   |   |   | |  |  |  | |      | |_    _|  /     \\ \n");
    printf("             |    \\_/    | |   \\/   | |  ___/    |  |   |   _   |\n");
    printf("             |           |  \\      /   \\___ \\    |  |   |  |_|  |\n");
    printf("             |   |\\_/|   |   \\    /    /     |   |  |   |   _   |\n");
    printf("             |   |   |   |    |  |    |      |  _|  |_  |  | |  |\n");
    printf("             |___|   |___|    |__|    |_____/  |______| |__| |__|\n");
    terminal_setcolor(15); // white
}
