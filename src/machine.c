#include "machine.h"
#include "inst.h"
#include <stddef.h>
#include <stdio.h>

void stack_push(Machine *mach, int val);
int stack_pop(Machine *Mach);

void machine_init(Machine *mach, Inst *prog, size_t prog_len) {
    mach->prog = prog;
    mach->prog_len = prog_len;
    mach->prog_ptr = 0;
    mach->stack_ptr = 0;
}

void machine_exec(Machine *mach) {
    printf("== exec ==\n");
#define BINOP(op)                                                              \
    do {                                                                       \
        int b = stack_pop(mach);                                               \
        int a = stack_pop(mach);                                               \
        stack_push(mach, a op b);                                              \
    } while (0)

    for (size_t i = 0; i < mach->prog_len; ++i) {
        Inst inst = mach->prog[i];
        switch (inst.op) {
        case OP_PUSH: {
            stack_push(mach, inst.operand.value);
        } break;
        case OP_POP: {
            if (inst.operand.value == -1)
                stack_pop(mach);
            else
                mach->regs[inst.operand.value] = stack_pop(mach);

        } break;
        case OP_BINOP: {
            switch (inst.operand.binop) {
            case '+': {
                BINOP(+);
            } break;
            case '-': {
                BINOP(-);
            } break;
            case '*': {
                BINOP(*);
            } break;
            case '/': {
                BINOP(/);
            } break;
            case '%': {
                BINOP(%);
            } break;
            default: {
                fprintf(stderr, "[ERROR] Unknown binary op '%c'\n",
                        inst.operand.binop);
            } break;
            }
        } break;
        case OP_PRINT: {
            printf("%d\n", stack_pop(mach));
        } break;
        }
    }

#undef BINOP
}

void machine_debug(Machine *mach) {
    printf("== disp ==\n");
    for (size_t i = 0; i < mach->prog_len; ++i) {
        Inst inst = mach->prog[i];
        printf("%04zu: ", i);
        switch (inst.op) {
        case OP_PUSH: {
            printf("OP_PUSH  -> %d", inst.operand.value);
        } break;
        case OP_POP: {
            printf("OP_POP");
        } break;
        case OP_BINOP: {
            printf("OP_BINOP -> '%c'", inst.operand.binop);
        } break;
        case OP_PRINT: {
            printf("OP_PRINT");
        } break;
        default: {
            fprintf(stderr, "Unhandled Operation: %d", inst.op);
        } break;
        }
        printf("\n");
    }
    printf("== stack ==\n");
    for (size_t i = 0; i < mach->stack_ptr; ++i) {
        int stack_item = mach->stack[i];
        printf("%04zu: 0x%X", i, stack_item);
    }
    printf("== regs ==\n[ ");
    for (size_t i = 0; i < REGISTER_COUNT; ++i) {
        int stack_item = mach->regs[i];
        printf("0x%X", stack_item);
        if (i != REGISTER_COUNT - 1)
            printf(", ");
    }
    printf(" ]\n");
}

// STACK
void stack_push(Machine *mach, int val) {
    mach->stack[++mach->stack_ptr] = val;
}
int stack_pop(Machine *mach) { return mach->stack[mach->stack_ptr--]; }
