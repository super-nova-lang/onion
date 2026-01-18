#pragma once
#include <stddef.h>

#include "inst.h"

#define STACK_MAX_SIZE 1024
typedef struct {
    /* Program */
    Inst *prog;
    size_t prog_ptr;
    size_t prog_len;

    /* Stack */
    int stack[STACK_MAX_SIZE];
    size_t stack_ptr;
} Machine;

void machine_init(Machine *mach, Inst *prog, size_t prog_len);
void machine_exec(Machine *mach);
void machine_disp(Machine *mach);

void machine_debug(Machine *mach);
