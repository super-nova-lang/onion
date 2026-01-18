#include <stdbool.h>

#include "file.h"
#include "inst.h"
#include "machine.h"

#include "../vendor/c-flags.h"

#define PROG_LEN (sizeof(prog) / sizeof(prog[0]))
Inst prog[] = {
    DEF_PUSH_INT(5), DEF_PUSH_INT(4), DEF_BINOP('+'), DEF_POP_TO(0),
    DEF_PUSH_INT(2), DEF_PUSH_INT(1), DEF_BINOP('-'), DEF_POP_TO(1),
    DEF_PUSH_INT(2), DEF_PUSH_INT(7), DEF_BINOP('*'), DEF_POP_TO(2),

};

Machine mach = {0};

int main(int argc, char **argv) {
    if (argc > 0)
        c_flags_set_application_name(argv[0]);

    c_flags_set_description("A VM for Novac");
    c_flags_set_positional_args_description("<file-path>");

    bool *bytecode = c_flag_bool("bytecode", "bc",
                                 "generate bytecode from <file-path>", false);
    bool *help = c_flag_bool("help", "h", "show usage", false);
    c_flags_parse(&argc, &argv, false);

    if (*help) {
        c_flags_usage();
        return 0;
    }

    if (argc == 0) {
        printf("ERROR: required file path not specified\n\n");
        c_flags_usage();
        return 1;
    }

    char *file_path = argv[0];
    if (*bytecode) {
        machine_init(&mach, prog, PROG_LEN);
        file_from_machine(&mach, file_path);
    } else {
        file_to_machine(&mach, file_path);
        machine_exec(&mach);
        machine_debug(&mach);
    }
}
