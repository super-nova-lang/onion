#include <stddef.h>

#include "machine.c"
#include "opcode.c"

Inst prog[] = {
    {.op = OP_PUSH, .value = 0x1},
    {.op = OP_PUSH, .value = 0x2},
    {.op = OP_ADD},
    {.op = OP_PRINT},
};

int main() {
    Machine mach = {0};
    machine_from_file(&mach, "out.onion");
    // machine_init(&mach, prog, sizeof(prog) / sizeof(prog[0]));
    machine_run(&mach);
    machine_print(&mach);
    machine_to_file(&mach, "out.onion");
}
