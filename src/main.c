#include <stdio.h>
#include <stdlib.h>

#define UNREACHABLE(msg)                                                       \
    do {                                                                       \
        fprintf(stderr, "UNREACHABLE: " msg);                                  \
        exit(1);                                                               \
    } while (0);

typedef enum {
    OP_PUSH,
    OP_POP,
    OP_ADD,
    OP_PRINT,
} Op;

typedef struct {
    Op op;
    int value;
} Inst;

#define STACK_MAX_SIZE 256
int stack[STACK_MAX_SIZE] = {0};
int stack_pointer = 0;
Inst program[] = {
    {.op = OP_PUSH, .value = 1},
    {.op = OP_PUSH, .value = 2},
    {.op = OP_PUSH, .value = 3},
    {.op = OP_ADD},
    {.op = OP_ADD},
    {.op = OP_PRINT},
};

void stack_push(int value);
int stack_pop();

void prog_run();
void prog_print();

int main() {
    prog_run();
    prog_print();
    return 0;
}

void stack_push(int value) { stack[stack_pointer++] = value; }
int stack_pop() { return stack[--stack_pointer]; }

void prog_run() {
#define BINOP(op)                                                              \
    do {                                                                       \
        int b = stack_pop();                                                   \
        int a = stack_pop();                                                   \
        stack_push(a op b);                                                    \
    } while (0);

    for (int i = 0; i < sizeof(program) / sizeof(program[0]); ++i) {
        Inst inst = program[i];
        switch (inst.op) {
        case OP_PUSH:
            stack_push(inst.value);
            break;
        case OP_POP:
            stack_pop();
            break;
        case OP_ADD:
            BINOP(+);
            break;
        case OP_PRINT:
            printf("%d\n", stack_pop());
            break;
        default:
            UNREACHABLE("OP");
        }
    }

#undef BINOP
}

void prog_print() {
    for (int i = 0; i < sizeof(program) / sizeof(program[0]); ++i) {
        Inst inst = program[i];
        printf("%04d: ", i);
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
        case OP_PRINT:
            printf("OP_PRINT");
            break;
        default:
            UNREACHABLE("OP");
        }
        printf("\n");
    }
}
