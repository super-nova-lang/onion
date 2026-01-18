#include <stddef.h>

#include "machine.c"

int main() {
    Machine mach = {0};
    machine_from_file(&mach, "out.onion", 16);
    machine_run(&mach);
    machine_to_file(&mach, "out.onion");
}
