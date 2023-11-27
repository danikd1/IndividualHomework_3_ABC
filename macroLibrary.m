# Macro library
#-----------------------------------------------------------------------------
# Распечатать строку
.macro print_str (%x) # (x - Строка, которую необходимо напечатать. Эта строка будет вставлена в сегмент данных и затем напечатана)
.data
str: .asciz %x 		# Определяет строку в сегменте данных
.text
   push(a0) 		# Сохраняет значение регистра a0 на стеке
   li a7 4		# Устанавливает номер системного вызова для печати строки
   la a0 str 		# Загружает адрес строки в регистр a0
   ecall
   pop(a0)		# Восстанавливает значение регистра a0 со стека
.end_macro

#-----------------------------------------------------------------------------
# Получить строку от пользователя, возвращается строка в буфере
.macro get_string(%buf, %size) #(buf - Адрес буфера, в который будет сохранена введенная пользователем строка, size - Размер буфера, доступный для ввода строки.)
    la a0 %buf		#Загружает адрес буфера для ввода строки
    li a1 %size 	# Устанавливает размер буфера
    li a7 8
    ecall
    
    push(s0)		# Сохраняет регистры s0, s1, s2 на стеке
    push(s1)
    push(s2)
    
    li	s0 '\n' 	# Устанавливает символ новой строки в s0
    la	s1 %buf		# Загружает адрес буфера в s1
next:
    lb s2 (s1) 		# Загружает байт из буфера в s2
    beq s0 s2 replace	# Сравнивает с символом новой строки
    addi s1 s1 1
    b next
replace:
    sb	zero (s1)	# Заменяет символ новой строки на нулевой байт
    
    pop(s2) 		# Восстанавливает регистры s2, s1, s0 со стека
    pop(s1)
    pop(s0)
.end_macro

#-----------------------------------------------------------------------------
# Открыть файл, file_name - имя файла, x - режим открытия, возвращает дескриптор или -1
.eqv READ 0	# for reading
.eqv WRITE 1	# for writing
.eqv APPEND 9	# for adding

.macro open(%file_name, %x) #(file_name - Адрес строки, содержащей имя файла, который нужно открыть, x - Режим открытия файла (например, READ, WRITE или APPEND)).
    la a0 %file_name 	# Загружает адрес имени файла
    li a1 %x		# Устанавливает режим открытия файла
    li a7 1024		# Устанавливает номер системного вызова для открытия файла
    ecall
.end_macro

#-----------------------------------------------------------------------------
# Получить динамическую память, size - необходимый размер, возвращает адрес
.macro allocate_memory(%size) #(size - Размер блока памяти, который нужно выделить.)
    li a0, %size	# Устанавливает размер запрашиваемой памяти
    li a7, 9		# Устанавливает номер системного вызова для выделения памяти
    ecall
.end_macro

#-----------------------------------------------------------------------------
# Читать информацию из открытого файла, file - дескриптор, buf - буфер, size - размер"
.macro read(%file, %buf, %size) #(file - Дескриптор файла, из которого нужно произвести чтение, buf - Адрес буфера, в который будут сохранены прочитанные данные, 
#size - Размер данных, которые нужно прочитать из файла)
    li   a7 63		# Устанавливает номер системного вызова для чтения из файла
    mv   a0 %file	# Устанавливает дескриптор файла
    la   a1 %buf	# Загружает адрес буфера
    li   a2 %size	# Устанавливает размер читаемых данных
    ecall 
.end_macro

#-----------------------------------------------------------------------------
.macro read_from_registr(%file, %reg, %size) #(file - Дескриптор файла, из которого производится чтение, reg - Регистр, в который будут загружены прочитанные данные, 
#size - Размер данных для чтения)
    li   a7, 63       # Устанавливает номер системного вызова для чтения из файла
    mv   a0, %file	# Устанавливает дескриптор файла
    mv   a1, %reg	# Регистр, в который будут загружены прочитанные данные
    li   a2, %size	# Устанавливает размер читаемых данных
    ecall
.end_macro

#-----------------------------------------------------------------------------
# Закрыть файл
.macro close(%file) #(file - Дескриптор файла, который нужно закрыть)
    mv   a0, %file
    li   a7, 57
    ecall
.end_macro

#-----------------------------------------------------------------------------
# Сохранить регистр на стеке, x - регистр для сохранения на стеке
.macro push(%x) #(x - Регистр, который необходимо сохранить на стеке (push))
	addi sp sp -4
	sw %x (sp)
.end_macro

#-----------------------------------------------------------------------------
# Загрузить регистр со стека, x - регистр для загрузки
.macro pop(%x)	#(x - Регистр, который необходимо восстановить со стека (pop).
	lw	%x, (sp)
	addi	sp, sp, 4
.end_macro

#-----------------------------------------------------------------------------
# Завершить программу
.macro exit
    li a7, 10
    ecall
.end_macro