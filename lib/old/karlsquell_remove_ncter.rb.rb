 


while gets
	puts($_.sub(/(NTR)\d+/, '\1').sub(/(CTR)\d+/, '\1'))
end