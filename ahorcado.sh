#!/bin/bash

die() {
	echo "$*" >&2
	exit 1
}

errmsg() {
	echo "$*" >&2
}

ayuda() {
	script=${0##*/}
	echo "Uso: $script <-f FILE>"
	exit 0
}

[[ $# == 0 ]] && ayuda

while getopts hf: opt; do
	case $opt in
		f)
			dict="$OPTARG"
			;;
		h)
			ayuda
			;;
		*)
			die "Opcion no valida."
			;;
	esac
done

[[ -f $dict ]] || die "No se encontro un diccionario."

mapfile -t palabras < "$dict"

r=$((RANDOM%${#palabras[@]}))
pal=${palabras[$r]}
n=${#pal}
out=${pal//?/_}
todos=

while (( ${intentos:-0} < ${#pal} )); do
	read -p "Intentos: " intentos

	case $intentos in
		*[!0-9]*)
			errmsg "Valor no valido."
			intentos=
			;;
		*)
			if (( intentos < ${#pal} )); then
				printf "%d: cantidad muy baja.\n" $intentos
			fi
			;;
	esac
done

while [[ $pal != $out ]] && (( intentos > 0  )); do
	printf "%-${n}s [intentos: %d]\n" $out $intentos
	pal_tmp=$pal
	indices=()
	read -n1 -p "Ingrese un caracter: " car
	printf "\n"
	case $todos in
		*$car* )
			printf "'$car': ya se ingreso.\n"
			continue
			;;
		*)
			todos=$todos$car
			;;
	esac
	case $pal in
		*$car*)
			for ((i = 0; i < $n; ++i)); do
				temp=${pal_tmp#?}
				char=${pal_tmp%$temp}
				pal_tmp=$temp
				[[ $char == $car ]] && indices+=( $i )
			done
			;;
		*)
			;;
	esac
	for x in ${indices[@]}; do
		((x++))
		out=${out:0:$((x-1))}$car${out:$x}
	done
	((intentos--))
done

[[ $pal == $out ]] && printf "***Ganaste***\n"
printf "La palababra era '$pal'.\n"
