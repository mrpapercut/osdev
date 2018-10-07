.global outb

outb:
    mov 8(%esp), %al
    mov 4(%esp), %dx
    out %al, %dx
    ret
