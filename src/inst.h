#pragma once
#include <stdbool.h>

typedef union {
    int value;
    char binop;
} Operand;

typedef enum {
    // STACK
    OP_PUSH,
    OP_POP,
    // REGISTERS
    OP_REG_POP,
    OP_REG_SET,
    // MATH
    OP_BINOP,
    // CALLS
    OP_PRINT,
} OpCode;

#define ARGS_COUNT 2
typedef struct {
    OpCode op;
    Operand operand;
    int args[ARGS_COUNT];
} Inst;

// Helper macros
#define DEF_PUSH_INT(arg)                                                      \
    (Inst) {                                                                   \
        .op = OP_PUSH, .operand = {.value = arg }                              \
    }

#define DEF_BINOP(arg)                                                         \
    (Inst) {                                                                   \
        .op = OP_BINOP, .operand = {.binop = arg }                             \
    }

#define DEF_POP()                                                              \
    (Inst) { .op = OP_POP, .operand = {.value = -1} }

#define DEF_REG_POP(reg)                                                       \
    (Inst) {                                                                   \
        .op = OP_REG_POP, .operand = {.value = reg }                           \
    }

#define DEF_REG_SET(a, b)                                                      \
    (Inst) {                                                                   \
        .op = OP_REG_SET, .args = { a, b }                                     \
    }

#define DEF_POP_TO(arg)                                                        \
    (Inst) {                                                                   \
        .op = OP_POP, .operand = {.value = arg }                               \
    }

#define DEF_PRINT()                                                            \
    (Inst) { .op = OP_PRINT }
