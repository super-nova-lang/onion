#include "file.h"
#include "inst.h"
#include <stdio.h>
#include <stdlib.h>

void file_to_machine(Machine *mach, char *file_path) {
    FILE *fp = fopen(file_path, "rb");
    if (!fp) {
        perror("Error opening file");
        exit(EXIT_FAILURE);
    }
    fseek(fp, 0, SEEK_END);
    long file_size = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    int count = file_size / sizeof(Inst);
    mach->prog = (Inst *)malloc(count * sizeof(Inst));
    if (!mach->prog) {
        perror("Memory allocation failed");
        fclose(fp);
        exit(EXIT_FAILURE);
    }
    size_t elements_read = fread(mach->prog, sizeof(Inst), count, fp);
    if (elements_read != (size_t)count) {
        fprintf(stderr, "Error reading file: expected %d elements, got %zu\n",
                count, elements_read);
        free(mach->prog);
        fclose(fp);
        exit(EXIT_FAILURE);
    }
    mach->prog_len = count;
    fclose(fp);
}

void file_from_machine(Machine *mach, char *file_path) {
    FILE *fp = fopen(file_path, "wb");
    if (!fp) {
        perror("Error opening file for writing");
        exit(EXIT_FAILURE);
    }
    size_t elements_written =
        fwrite(mach->prog, sizeof(Inst), mach->prog_len, fp);
    if (elements_written != mach->prog_len) {
        fprintf(stderr,
                "Error writing file: expected %zu elements, wrote %zu\n",
                mach->prog_len, elements_written);
        fclose(fp);
        exit(EXIT_FAILURE);
    }
    fclose(fp);
}
