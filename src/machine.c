#ifndef MACHINE_H_
#define MACHINE_H_

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <string.h>

#include "opcode.c"

#define LIST_LEN(list) (sizeof(list) / sizeof(list[0]))

#define ONION_VERSION "0.1.0"
#define MAGIC "ONION " ONION_VERSION
#define MAGIC_SIZE sizeof(MAGIC)

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
void machine_from_file(Machine *mach, char *filepath);

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
    if (!fp) {
        perror("fopen");
        exit(1);
    }
    /* write magic (without null terminator) */
    if (fwrite(MAGIC, 1, MAGIC_SIZE, fp) != MAGIC_SIZE) {
        perror("fwrite");
        fclose(fp);
        exit(1);
    }
    if (fwrite(mach->prog, sizeof(Inst), mach->prog_len, fp) != mach->prog_len) {
        perror("fwrite");
        fclose(fp);
        exit(1);
    }
    fclose(fp);
}

void machine_from_file(Machine *mach, char *filepath) {
    FILE *fp = fopen(filepath, "rb");
    if (!fp) {
        perror("fopen");
        exit(1);
    }
    struct stat file_stat;
    if (stat(filepath, &file_stat) != 0) {
        perror("stat");
        fclose(fp);
        exit(1);
    }
    if (file_stat.st_size < MAGIC_SIZE) {
        fprintf(stderr, "ERROR: file too small\n");
        fclose(fp);
        exit(1);
    }
    size_t prog_bytes = file_stat.st_size - MAGIC_SIZE;
    if (prog_bytes % sizeof(Inst) != 0) {
        fprintf(stderr, "ERROR: invalid program size\n");
        fclose(fp);
        exit(1);
    }
    size_t prog_len = prog_bytes / sizeof(Inst);

    /* read and validate magic */
    char *magic_buf = malloc(MAGIC_SIZE);
    if (!magic_buf) {
        fprintf(stderr, "ERROR: malloc failed\n");
        fclose(fp);
        exit(1);
    }
    if (fread(magic_buf, 1, MAGIC_SIZE, fp) != MAGIC_SIZE) {
        perror("fread");
        free(magic_buf);
        fclose(fp);
        exit(1);
    }
    if (memcmp(magic_buf, MAGIC, MAGIC_SIZE) != 0) {
        fprintf(stderr, "ERROR: bad magic\n");
        free(magic_buf);
        fclose(fp);
        exit(1);
    }
    free(magic_buf);

    Inst *prog = malloc(sizeof(Inst) * prog_len);
    if (!prog) {
        fprintf(stderr, "ERROR: malloc failed\n");
        fclose(fp);
        exit(1);
    }
    if (fread(prog, sizeof(Inst), prog_len, fp) != prog_len) {
        perror("fread");
        free(prog);
        fclose(fp);
        exit(1);
    }
    fclose(fp);

    mach->prog = prog;
    mach->prog_len = prog_len;
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
