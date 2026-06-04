/* Test the usage of option -Wstrict-aliasing.  */
/* Make sure it's enabled even when -fno-strict-aliasing.  */
/* { dg-do compile } */
/* { dg-options "-Wstrict-aliasing -fno-strict-aliasing" } */

int main(int argc, char *argv[])
{
    int x;
    float *q = (float*) &x; /* {dg-warning "strict-aliasing"} */
    return x;
}
