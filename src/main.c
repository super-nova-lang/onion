#include "inst.h"
#include "machine.h"

#define PROG_LEN (sizeof(prog) / sizeof(prog[0]))
Inst prog[] = {
    DEF_PUSH_INT(5),
    DEF_PUSH_INT(4),
    DEF_BINOP('+'),
    DEF_PRINT(),
};

Machine mach = {0};

int main(int argc, char **argv) {
    machine_init(&mach, prog, PROG_LEN);
    machine_exec(&mach);
    machine_debug(&mach);
}
