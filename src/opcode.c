#ifndef OPCODE_H_
#define OPCODE_H_

typedef enum {
    OP_PUSH,
    OP_POP,
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_MOD,
    OP_PRINT,
} Op;

typedef struct {
    Op op;
    int value;
} Inst;

#endif // OPCODE_H_
