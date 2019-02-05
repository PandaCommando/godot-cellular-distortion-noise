extends Sprite

export var noise_x = 0
export var noise_y = 0

export var width = 1
export var height = 1

var octaves = 9

func _ready():
	var data = get_area(noise_x,noise_y,width,height,octaves)
	
	var image = Image.new()
	var img_res_w = data.size()
	var img_res_h = data[0].size()
	image.create(img_res_w,img_res_h,false,Image.FORMAT_RGBA8)
	
	image.lock()
	
	for X in img_res_w:
		for Y in img_res_h:
			image.set_pixel(X,Y,data[X][Y])
	
	image.unlock()
	
	var it = ImageTexture.new()
	it.create_from_image(image)
	it.set_flags(it.FLAG_ANISOTROPIC_FILTER)
	texture = it
	
	scale = Vector2(1,1)*257/data.size()

func get_area(x,y,width,height,octaves):
	#x and y correspond to the top left white noise cell
	#width/height correspond to the amount of white noise squares you want to generate
	#octaves are the levels of detail, each octave increases the output resolution: 2^octaves
	
	var data = [[]]
	for X in width+2:
		data[0].append([])
		for Y in height+2:
			seed(hash([x+X-1,y+Y-1]))
			var v = randi()
			data[0][X].append(Color8(rand_range(0,255),rand_range(0,255),rand_range(0,255),255))
	
	for o in octaves-1:

		data.append([])
		var oct = o+1
		var oct_width = (data[o].size()*2)-1
		var oct_height = (data[o][0].size()*2)-1
		print(oct_width)
		print("~")
		print(pow(2,o+2)*(width-1)+1)
		for X in oct_width:
			data[oct].append([])
			for Y in oct_height:
				var par_x = floor(X*0.5)
				var par_y = floor(Y*0.5)
				var rpx = (x - 1)*oct_width/(width+1)+X
				var rpy = (y - 1)*oct_height/(height+1)+Y
				seed(seed_coord(rpx,rpy,o))
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
				data[oct][X].append(val)
	
	
	return data[octaves-1]



func seed_coord(x,y,o):
	var sx = seed2(x * 1947)
	var sy = seed2(y * 2904)
	var so = seed2(o * 5307)
	return seed2(sx ^ sy ^ so)

func seed2(_s):
	var s = 192837463 ^ int(abs(_s))
	var a = 1664525
	var c = 1013904223
	var m = 4294967296
	return((s * a + c) % m)