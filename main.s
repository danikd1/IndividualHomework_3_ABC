.include "file-helper.s"

.eqv     STR_SIZE 256

.data
	output_str:   .asciz  
	.space STR_SIZE
	
	file_name: .space NAME_SIZE 	# Имя читаемого файла
	strbuf: .space TEXT_SIZE	# Буфер для читаемого текста

.global error_name, er_read, main
	
.text	
main:
	print_str("Input file path: ")

	get_string(file_name, NAME_SIZE) #Вводим имя файла с консоли 

	open(file_name, READ) #Открываем файл на чтение

	jal func

	li s0 65 	#ASCII-код 'A'
	li s1 90 	#ASCII-код 'Z'
	li s2 97 	#ASCII-код 'a'
	li s3 122	#ASCII-код 'z'
	li s4 1		
	li s5 32 	#space
	li t0 1 	#flag 
	
	la a4 output_str
	mv a5 a4
	
#проверяем тип символа и читаем посимвольно строку
loop: 
	bgtu a0 a1 str_end  	#проверка условия конца строки
	lb a3 (a0) 		#считываем символ из исходной строки 
	blt a3 s0 symbol 	# if a3 < 65 ('A') --> символ (S)
	bgt a3 s3 symbol 	# if a3 > 122 ('z') --> символ (S)
	blt a3 s1 capital_case 	# if a3 < 90 ('Z') --> заглавная буква (S)
	bgt a3 s2 lower_case 	# if a3 > 97 ('a') --> строчная буква (S)
	j symbol

#Если полученная буква явл. заглавной, то начинаем копировать это слово	при условии, что flag != 0
#Если flag == 0, значит слово начинается не с заглавной буквы и мы должны пропустить эту букву
capital_case:
	beqz t0 lower_case 	#если flag = 0, то слово начинается не с заглавной буквы
	sb a3 (a4) 		 #записываем значение из a3 в a4
	addi a0 a0 1  		#следующий символ
	addi a4 a4 1 	
	li t0 2	 		#flag установлен на 2 - значит слова найдено
	j loop

#Если flag = 2, это значит, что следующие строчные буквы относятся к нашему слову, начинающемуся с заглавной буквы, в остальных случаях строчные буквы по пропускаем. 
lower_case:
	bgt t0 s4 capital_case  #если flag = 2, то в найденном слове есть строчные буквы
	addi a0 a0 1		#следующий символ
	li t0 0 		#flag установлен на 0 - значит итерация идет по строчным символам
	j loop
	
#проверяем достигнут ли конец слова
symbol:
 	bgt t0 s4 save_word  #если flag = 2, то мы дошли до конца слова
 	
#пропускаем символы и устонавливаем флаг
symbol_2:
	addi a0 a0 1	#следующий символ
	li t0 1 	#flag установлен на 1 - значит был найден символ
	j loop
	
#добовляем пробел для формирования итоговой строки	
save_word:
	sb s5 (a4)  	#записываем пробел в a4
	addi a4 a4 1	#следующий символ
	j symbol_2
	
#Вывод итоговой строки на консоль и в файл
str_end:
	la a0 output_str
	la t2 output_str
	li a7 4
	ecall
	
	print_str ("\nInput path to file for writing: ")
	
    	get_string(file_name, NAME_SIZE) 	# Ввод имени файла с консоли эмулятора
    	
    	open(file_name, WRITE)		#Открываем файл на запись
    	
   	 li	t0 -1			# Проверка на корректное открытие
   	 beq	a0 t0 error_name	# Ошибка открытия файла
   	 mv   	t1 a0       		# Сохранение дескриптора файла
   	 li   a7, 64       		# Системный вызов для записи в файл
   	 mv   a0, t1			# Дескриптор файла
   	 mv   a1, t2  			# Адрес буфера записываемого текста
   	 mv   a2, t5    		# Размер записываемой порции из регистра
   	 ecall             		# Запись в файл
	
exit  #макрос завершения программы

#Выводим информацию о неверном названии введенного пользователем файла и завершаем программу
error_name:
	print_str("Incorrect file name\n")
	exit
#Завершаем программу
er_read:
	exit
	
	
