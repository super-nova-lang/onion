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
    // MATH
    OP_BINOP,
    // CALLS
    OP_PRINT,
} OpCode;

typedef struct {
    OpCode op;
    Operand operand;
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

#define DEF_POP_TO(arg)                                                        \
    (Inst) {                                                                   \
        .op = OP_POP, .operand = {.value = arg }                               \
    }

#define DEF_PRINT()                                                            \
    (Inst) { .op = OP_PRINT }
