from PIL import Image
import numpy as np
import os
import pandas as pd
import time

#loc='//tx1cifs/tx1data/Austin Share/Detectors Of Engagement IES Goal 1/Secure Study Data/Learn Bop Data/Images/'
#loc='/Volumes/tx1data/Austin Share/Detectors Of Engagement IES Goal 1/Secure Study Data/Learn Bop Data/Images/'
loc = '/Users/jmeakin/Desktop/Images/Images/'
img = '16794_20_5 (1).jpg'
im = Image.open(loc+img)
im.show()



# Create List Of Photos
photolist=[]
for subdir, dirs, files in os.walk(loc):
	for file in files:
		if file.find('.jpg')!=-1:
			photolist.append(os.path.join(subdir, file))
print(len(photolist))


#photolist=photolist[0:100]


# Create A Data Frame All PhotoIds
start = time.time()
iteration = 0
photo_frame = pd.DataFrame()
for picture in photolist:
		im = Image.open(picture)
		pixels = im.getdata()
		identifier = im.tobytes()

		dataframe = pd.DataFrame(columns=['Learnbop_Id', 'photo_id'])
		dataframe.loc[0] = 0
		picname1 = str(picture).replace(str(loc),"")
		picname2 = str(picname1).replace(".jpg","")

		dataframe['Learnbop_Id']=picname2

		dataframe['photo_id'] = identifier
		photo_frame = pd.concat([photo_frame, dataframe], ignore_index=True)
		print("total time taken this loop: ", time.time() - start)
		iteration = iteration+1
		print(iteration)


# Generate Counter For Dups
start = time.time()
iteration = 0
photo_frame.sort_values(by=['photo_id'], inplace=True)
photo_frame.reset_index(inplace=True)
photo_frame['dupcount'] = None
photo_frame['dupcount'][0] = 1
for i in range(1,len(photo_frame)):
	if photo_frame['photo_id'][i]==photo_frame['photo_id'][i-1]:
		photo_frame['dupcount'][i]=photo_frame['dupcount'][i-1]+1
	else:
		photo_frame['dupcount'][i]=1

	print("total time taken this loop: ", time.time() - start)
	iteration = iteration+1
	print(iteration)

start = time.time()
wide_frame = photo_frame.pivot(index='photo_id', columns='dupcount', values='Learnbop_Id')
print("total time taken reshape: ", time.time() - start)

#writer = pd.ExcelWriter('//tx1cifs/tx1data/Austin Share/Detectors Of Engagement IES Goal 1/Secure Study Data/Learn Bop Data/PhotoDuplicates.xlsx', engine='xlsxwriter')
#writer = pd.ExcelWriter('/Volumes/tx1data/Austin Share/Detectors Of Engagement IES Goal 1/Secure Study Data/Learn Bop Data/PhotoDuplicates.xlsx', engine='xlsxwriter')
writer = pd.ExcelWriter('/Users/jmeakin/Desktop/Images/Images/PhotoDuplicates.xlsx', engine='xlsxwriter')
workbook  = writer.book
wide_frame.to_excel(writer, sheet_name='PhotoDuplicates', index=False)
writer.save()