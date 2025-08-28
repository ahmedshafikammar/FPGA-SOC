#include <stdio.h>
#include "platform.h"
#include "xgpio.h"
#include "xparameters.h"
#include <unistd.h>

long long mod_pow(long long base, long long exp, long long mod) {
    long long result = 1;
    while (exp > 0) {
        if (exp % 2 == 1) {
            result = (result * base) % mod;
        }
        base = (base * base) % mod;
        exp /= 2;
    }
    return result;
}

long long encrypt(int message, int e, int n) {
    return mod_pow(message, e, n);
}

long long decrypt(long long ciphertext, int d, int n) {
    return mod_pow(ciphertext, d, n);
}

int main() {
    init_platform();

    int n = 15;
    int e = 7;
    int d = 3;

    XGpio input_botton_xpgio, input_message_xpgio, output_message_xpgio;
    int input_botton, input_message;

    XGpio_Initialize(&input_botton_xpgio, XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_Initialize(&input_message_xpgio, XPAR_AXI_GPIO_1_DEVICE_ID);
    XGpio_Initialize(&output_message_xpgio, XPAR_AXI_GPIO_2_DEVICE_ID);

    XGpio_SetDataDirection(&input_botton_xpgio,1,1);
    XGpio_SetDataDirection(&input_message_xpgio,1,1);
    XGpio_SetDataDirection(&output_message_xpgio,1,0);

    while(1) {
        do {
            input_botton = XGpio_DiscreteRead(&input_botton_xpgio, 1);
            input_message = XGpio_DiscreteRead(&input_message_xpgio, 1);
        } while (input_botton != 1);

        long long ciphertext = encrypt(input_message, e, n);
        XGpio_DiscreteWrite(&output_message_xpgio, 1, ciphertext);
        sleep(2);

        do {
            input_botton = XGpio_DiscreteRead(&input_botton_xpgio, 1);
        } while (input_botton != 1);

        long long decrypted_message = decrypt(ciphertext, d, n);
        XGpio_DiscreteWrite(&output_message_xpgio, 1, decrypted_message);
        sleep(2);
    }

    cleanup_platform();
    return 0;
}
