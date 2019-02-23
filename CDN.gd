extends Node

#replaces all values that are not "value" with "rvalue"
func area_extract(area,value,rvalue):
	
	var data = area.duplicate()
	
	for X in data.size():
		for Y in data[0].size():
			if(data[X][Y] != value):
				data[X][Y] = rvalue
	return data


#gets an area of whitenoise of your desired dimensions
func get_whitenoise(x,y,width,height):
	var data = []
	for X in width+2:
		data.append([])
		for Y in height+2:
			seed(seed_coord(x+X-1,y+Y-1))
			var v = randi()
			data[X].append(Color8(rand_range(0,255),rand_range(0,255),rand_range(0,255),255))
	return data


func continent_noise(x,y,width,height):
	var data = []
	
	var off = 4#minimum space between continents
	var continent_spawnrate = 0.6 #spawn percentage
	
	var off2 = off/2
	
	for X in width+2:
		data.append([])
		for Y in height+2:
			var rx = x+X
			var ry = y+Y
			
			seed(seed_coord(rx-1,ry-1))
			var v = randi()
			
			var spawn = false
			
			if(randf()<=continent_spawnrate):
				if((rx%off==0 && ry%off==0)||((rx-off2)%off==0 && (ry-off2)%off==0)):
					spawn = true
			
			if(spawn):
				data[X].append(Color8(rand_range(0,255),rand_range(150,255),rand_range(0,255),255))
			else: 
				data[X].append(Color8(rand_range(0,50),rand_range(0,50),255,255))
	return data


#gets a texture from an area
#only use areas where EVERY VALUE is a color or else it will crash
func get_texture_from_area(area):
	return get_texture_from_image(get_image_from_area(area))


#gets an image from an area
#only use areas where EVERY VALUE is a color or else it will crash
func get_image_from_area(area):
	var image = Image.new()
	var img_res_w = area.size()
	var img_res_h = area[0].size()
	image.create(img_res_w,img_res_h,false,Image.FORMAT_RGBA8)
	
	image.lock()
	
	for X in img_res_w:
		for Y in img_res_h:
			image.set_pixel(X,Y,area[X][Y])
	
	image.unlock()
	
	return(image)


#gets a crisp pixel texture from an image
func get_texture_from_image(image):
	var it = ImageTexture.new()
	it.create_from_image(image)
	it.set_flags(it.FLAG_ANISOTROPIC_FILTER)
	
	return(it)


#distorts the area you pass to it using cellular distortion noise
func area_distort(area,x,y,octaves):
	#x and y correspond to the top left white noise cell
	#octaves are the levels of detail, each octave increases the output resolution: (2^octaves)-1
	
	var data = [area]
	var width = area.size()-1
	var height = area[0].size()-1
	
	
	for o in octaves-1:

		data.append([])
		var oct_width = (data[o].size()*2)-1
		var oct_height = (data[o][0].size()*2)-1
		for X in oct_width:
			data[o+1].append([])
			for Y in oct_height:
				var par_x = floor(X/2)
				var par_y = floor(Y/2)
				var rpx = (x - 1)*floor(oct_width/width)+X
				var rpy = (y - 1)*floor(oct_height/height)+Y
				seed(seed_coord_octave(rpx,rpy,o))
				var v = randi()
				var val
				
				if X%2==0 && Y%2==0:
					val = data[o][par_x][par_y]
				elif X%2!=0 && Y%2==0:
					var set = [data[o][par_x][par_y],
							   data[o][par_x+1][par_y]]
					val = set[round(randf())]
				elif X%2!=0:
					var set = [data[o][par_x][par_y],
							   data[o][par_x+1][par_y],
							   data[o][par_x][par_y+1],
							   data[o][par_x+1][par_y+1]]
					val = set[round(randf()*3)]
				else:
					var set = [data[o][par_x][par_y],
							   data[o][par_x][par_y+1]]
			
					val = set[round(randf())]
				data[o+1][X].append(val)
				
	return data[octaves-1]


func seed_coord_octave(x,y,o):
	var sx = seed2(x * 1947)
	var sy = seed2(y * 2904)
	var so = seed2(o * 5307)
	return seed2(sx ^ sy ^ so)


func seed_coord(x,y):
	var sx = seed2(x * 1947)
	var sy = seed2(y * 2904)
	return seed2(sx ^ sy)


func seed2(_s):
	var s = 192837463 ^ int(floor(abs(_s)))
	var a = 1664525
	var c = 1013904223
	var m = 4294967296
	return((s * a + c) % m)