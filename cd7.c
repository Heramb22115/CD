#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

struct Quadruple {
    char op[5], arg1[20], arg2[20], res[20];
} q[20];

int n;

int isNumber(char *s) {
    for (int i = 0; s[i]; i++)
        if (!isdigit(s[i])) return 0;
    return 1;
}

void constantFolding() {
    for (int i = 0; i < n; i++) {
        if (isNumber(q[i].arg1) && isNumber(q[i].arg2)) {
            int a = atoi(q[i].arg1);
            int b = atoi(q[i].arg2);
            int result;

            if (strcmp(q[i].op, "+") == 0) result = a + b;
            else if (strcmp(q[i].op, "-") == 0) result = a - b;
            else if (strcmp(q[i].op, "*") == 0) result = a * b;
            else if (strcmp(q[i].op, "/") == 0 && b != 0) result = a / b;
            else continue;

            sprintf(q[i].arg1, "%d", result);
            strcpy(q[i].arg2, "-");
            strcpy(q[i].op, "=");
        }
    }
}

void commonSubexprElim() {
    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            if (strcmp(q[i].op, q[j].op) == 0 &&
                strcmp(q[i].arg1, q[j].arg1) == 0 &&
                strcmp(q[i].arg2, q[j].arg2) == 0) {
                strcpy(q[j].op, "=");
                strcpy(q[j].arg1, q[i].res);
                strcpy(q[j].arg2, "-");
            }
        }
    }
}

void copyPropagation() {
    for (int i = 0; i < n; i++) {
        if (strcmp(q[i].op, "=") == 0 && strcmp(q[i].arg2, "-") == 0) {
            char source[20];
            strcpy(source, q[i].arg1);
            char target[20];
            strcpy(target, q[i].res);
            for (int j = i + 1; j < n; j++) {
                if (strcmp(q[j].arg1, target) == 0)
                    strcpy(q[j].arg1, source);
                if (strcmp(q[j].arg2, target) == 0)
                    strcpy(q[j].arg2, source);
            }
        }
    }
}

int main() {
    printf("Enter number of Quadruples: ");
    scanf("%d", &n);
    printf("Enter Quadruples in format: op arg1 arg2 result\n");

    for (int i = 0; i < n; i++) {
        scanf("%s %s %s %s", q[i].op, q[i].arg1, q[i].arg2, q[i].res);
    }

    printf("\nIntermediate Code:\n");
    for (int i = 0; i < n; i++)
        printf("%s\t%s\t%s\t%s\n", q[i].op, q[i].arg1, q[i].arg2, q[i].res);

    constantFolding();
    commonSubexprElim();
    copyPropagation();

    printf("\nOptimized Code:\n");
    for (int i = 0; i < n; i++)
        printf("%s\t%s\t%s\t%s\n", q[i].op, q[i].arg1, q[i].arg2, q[i].res);

    return 0;
}

