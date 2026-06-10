def unpack_u8_vector(vec):
    """
    Splits a 32-bit packed vector into four unsigned 8-bit elements.

    Example:
    vec = 0x04030201
    returns [1, 2, 3, 4]
    """
    return [(vec >> (8 * i)) & 0xFF for i in range(4)]


def dot_product(vec_a, vec_b):
    """
    Computes unsigned 4-element dot product.

    vec_a and vec_b are 32-bit packed vectors.
    Each contains four unsigned 8-bit elements.
    """
    a = unpack_u8_vector(vec_a)
    b = unpack_u8_vector(vec_b)

    result = 0

    for i in range(4):
        result += a[i] * b[i]

    return result


def main():
    tests = [
        (0x0000000C, 0x00000007),
        (0x04030201, 0x08070605),
        (0x00000000, 0x06070809),
        (0xFFFFFFFF, 0xFFFFFFFF),
        (0x00000001, 0x06070809),
        (0x01000000, 0x06070809),
    ]

    for vec_a, vec_b in tests:
        result = dot_product(vec_a, vec_b)
        print(f"A=0x{vec_a:08X}, B=0x{vec_b:08X}, result={result}")


if __name__ == "__main__":
    main()