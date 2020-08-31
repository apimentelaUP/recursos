########################################################################
# Lo primero es obtener todos los links de descargas, Gutemberg tiene un
# servicio para eso, lo que quiero es obtener los textos en español, así
# que tengo que correr esta instrucción:
#
#	wget -w 2 -m "http://www.gutenberg.org/robot/harvest?filetypes[]=html&langs[]=es"
#
# Eso crea una carpeta (www.gutemberg.org) en la que se crea otra carpeta
# (robot) con todo el paginado de los links (comprimidos en zip), así que
# tengo que recorrer esos archivos, buscar los links y descargarlos

#~ for i in www.gutenberg.org/robot/*; do 
	#~ cat "$i" \
	#~ | grep -Po "href=\"\Khttp[^\"]+" > temp
	#~ wget -w 2 -i temp
#~ done

# ACTUALIZACION: estos comentarios ya los puse en código:
# Luego de eso, debo descomprimir todo, como pedí HTMLs, entonces hice
# una carpeta que se llamara así (HTMLs), copié todos los zip en esa carpeta
# y corrí los siguientes comandos (ya en la carpeta claro):

#~ if [[ ! -d HTMLs ]]; then
	#~ mkdir HTMLs
#~ fi

#~ cp *.zip HTMLs
cd HTMLs

#~ for i in *.zip; do unzip -o "$i" ; done
#~ rm *.zip
#~ find . -type f -regex ".*\.html?" -exec mv {} . \;
#~ rm -r */


#~ for i in *.htm* ; do 
	#~ # Primero debo ver qué codificación tienen para convertirlo
	
	#~ # La instrucción es para extraer la etiqueta "pre" de los textos, que
	#~ # es donde viene la información del autor, pero tienen dos, una al inicio
	#~ # y otra al final. Así que el pipe|head|tail es para obtener solo la primera
	#~ #	iconv -f ISO-8859-1 -t ascii//TRANSLIT//IGNORE
	#~ #	sed 'y/āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜĀÁǍÀĒÉĚÈĪÍǏÌŌÓǑÒŪÚǓÙǕǗǙǛ/aaaaeeeeiiiioooouuuuüüüüAAAAEEEEIIIIOOOOUUUUÜÜÜÜ/'
	
	#~ if file "$i" | grep -q ISO; then
		#~ autor=$(hxclean "$i" | hxselect pre | hxpipe | iconv -f ISO-8859-1 -t UTF-8 | head -2 | tail -1 | sed 'y/āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜĀÁǍÀĒÉĚÈĪÍǏÌŌÓǑÒŪÚǓÙǕǗǙǛ/aaaaeeeeiiiioooouuuuüüüüAAAAEEEEIIIIOOOOUUUUÜÜÜÜ/' \
		#~ | grep -Po "\\\\nAuthor: \K[^\\\\]+" | sed 's/ *$//' | perl -ne 'print lc' | tr -s " " | tr " " "_")
	#~ else
		#~ autor=$(hxclean "$i" | hxselect pre | hxpipe | head -2 | tail -1 | sed 'y/āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜĀÁǍÀĒÉĚÈĪÍǏÌŌÓǑÒŪÚǓÙǕǗǙǛ/aaaaeeeeiiiioooouuuuüüüüAAAAEEEEIIIIOOOOUUUUÜÜÜÜ/' \
		#~ | grep -Po "\\\\nAuthor: \K[^\\\\]+" | sed 's/ *$//' | perl -ne 'print lc' | tr -s " " | tr " " "_")
	#~ fi
	#~ echo -e "$i\t$autor"
#~ done

# Mas adelante, solo armo una lista con los autores de mayor publicaciones
# y los ordeno para quedarme con los mayores (en primer instancia tomé
# los que tenían 3 o más, le puse de nombre "temp.txt"
# La lista original de pares archivo-autor le puse "listaAutores.tsv"
# si paso ambos archivos a la carpeta de los htmls puedo correr el siguiente código:

awk '{print $2}' temp.txt | while read autor; do
	if [[ ! -d "$autor" ]]; then
		mkdir "$autor"
	fi
done

function mover {
	archivo="$1"
	autor="$2"
	if [[ -d "$autor" ]]; then
		mv "$archivo" "$autor"
	fi
}

cat listaAutores.tsv | while read par; do
	mover $par
done

rm *.htm*
