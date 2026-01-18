#ifndef MACHINE_H_
#define MACHINE_H_

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#include "opcode.c"

#define LIST_LEN(list) (sizeof(list) / sizeof(list[0]))

#define PROG_MAX_SIZE 2048
#define STACK_MAX_SIZE 256
#define REGISTER_COUNT 8
typedef struct {
    /* Program */
    Inst *prog;
    size_t prog_ptr;
    size_t prog_len;
    /* Stack */
    int stack[STACK_MAX_SIZE];
    size_t stack_ptr;
    /* Registers */
    int regs[REGISTER_COUNT];
} Machine;

void machine_init(Machine *mach, Inst *prog, size_t prog_len);
void machine_run(Machine *mach);
void machine_print(Machine *mach);
void machine_to_file(Machine *mach, char *filepath);
void machine_from_file(Machine *mach, char *filepath, size_t prog_size);

void stack_push(Machine *mach, int value);
int stack_pop(Machine *mach);

#define binop(mach, op)                                                        \
    do {                                                                       \
        int b = stack_pop(mach);                                               \
        int a = stack_pop(mach);                                               \
        stack_push(mach, a op b);                                              \
    } while (0);

void machine_init(Machine *mach, Inst *prog, size_t prog_len) {
    mach->prog = prog;
    mach->prog_len = prog_len;
}

void machine_run(Machine *mach) {
    printf("== running ==\n");
    for (size_t i = 0; i < mach->prog_len; ++i) {
        Inst inst = mach->prog[i];
        switch (inst.op) {
        case OP_PUSH:
            stack_push(mach, inst.value);
            break;
        case OP_POP:
            stack_pop(mach);
            break;
        case OP_ADD:
            binop(mach, +);
            break;
        case OP_SUB:
            binop(mach, -);
            break;
        case OP_MUL:
            binop(mach, *);
            break;
        case OP_DIV:
            binop(mach, /);
            break;
        case OP_MOD:
            binop(mach, %);
            break;
        case OP_PRINT:
            printf("%d\n", stack_pop(mach));
            break;
        default:
            fprintf(stderr, "ERROR: UNHANDLED INST: %d\n", inst.op);
            exit(1);
        }
    }
}

void machine_print(Machine *mach) {
    for (size_t i = 0; i < mach->prog_len; ++i) {
        Inst inst = mach->prog[i];
        printf("%04zu: ", i);
        switch (inst.op) {
        case OP_PUSH:
            printf("OP_PUSH -> 0x%X", inst.value);
            break;
        case OP_POP:
            printf("OP_POP");
            break;
        case OP_ADD:
            printf("OP_ADD");
            break;
        case OP_SUB:
            printf("OP_SUB");
            break;
        case OP_MUL:
            printf("OP_MUL");
            break;
        case OP_DIV:
            printf("OP_DIV");
            break;
        case OP_MOD:
            printf("OP_MOD");
            break;
        case OP_PRINT:
            printf("OP_PRINT");
            break;
        default:
            fprintf(stderr, "ERROR: UNHANDLED INST: %d\n", inst.op);
            exit(1);
        }
        printf("\n");
    }
    printf("== stack ==\n");
    for (size_t i = 0; i < mach->stack_ptr; ++i) {
        printf("%04zu: 0x%X\n", i, mach->stack[i]);
    }
}

void machine_to_file(Machine *mach, char *filepath) {
    FILE *fp = fopen(filepath, "wb");
    fwrite(mach->prog, sizeof(Inst), mach->prog_len, fp);
    fclose(fp);
}

void machine_from_file(Machine *mach, char *filepath, size_t prog_size) {
    FILE *fp = fopen(filepath, "rb");
    Inst *prog = malloc(sizeof(Inst) * prog_size);
    size_t read = fread(prog, sizeof(Inst), prog_size, fp);
    fclose(fp);
    mach->prog = prog;
    mach->prog_len = read;
    mach->prog_ptr = 0;
    mach->stack_ptr = 0;
    for (size_t i = 0; i < REGISTER_COUNT; ++i)
        mach->regs[i] = 0;
}

void stack_push(Machine *mach, int value) {
    mach->stack[mach->stack_ptr++] = value;
}
int stack_pop(Machine *mach) { return mach->stack[--mach->stack_ptr]; }

#endif // MACHINE_H_
