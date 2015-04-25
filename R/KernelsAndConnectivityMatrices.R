


cell <- 50
# landscape size
land.x <- 1000	# 1000 km = 1,000,000 m
land.y <- 2000		# 50 km = 50,000 m

cells.x <- land.x/cell
cells.y <- land.y/cell

(total.cells <- cells.x * cells.y)


# CREATE THE DISPERSAL MATRIX

# dispersal kernel from 1 patch to surrounding patches
#	want it to be Gaussian and vary to having more LDD (long distance dispersal)
dist.mean <- 0		# mean should stay at zero as dispersal is centered around natal patch
dist.sd <- 25		# this is sigma, one standard deviation, in meters


make.kernel.and.matrix <- function(cell.size, land.x, land.y, dist.mean=0, dist.sd, breed.window=FALSE, two.kernels=FALSE, second.dist.mean=0, second.dist.sd=NULL){

	cells.x <- land.x/cell
	cells.y <- land.y/cell

	total.cells <- cells.x * cells.y

	# scale the landscape, and want to cut off at 4 sigma, so how many cells (in 1-D) are there within 4 sigma:
	units <- dist.sd/cell		# number of cells per one sigma
	four.sigma.units <- 4*units	# number of cells per four sigma IN ONE DIRECTION

	center.cell <- four.sigma.units + 1
	cells.in.1D.kernel <- four.sigma.units + four.sigma.units + 1
			# total cells going across the one-dimensional kernel are those one either side plus the central/natal one

	# make the 1-D kernel
	kernel.1d <- rep(NA, cells.in.1D.kernel)
	k <- 1
	for(i in -four.sigma.units:four.sigma.units){
		left.boundary <- (i-0.5)*cell
		right.boundary <- (i+0.5)*cell
		kernel.1d[k] <- pnorm(q=right.boundary, sd=dist.sd) - pnorm(q=left.boundary, sd=dist.sd)
		k <- k+1
	}

	# actually just take the first half and copy it to the second half, because the numbers slightly differ at the 12th decimal place otherwise.
	# might be slightly inaccurate, but will ensure accuracy down the line and a perfect mirror image
	kernel.1d <- c(kernel.1d[1:center.cell], kernel.1d[(center.cell-1):1])

		# correct to have the halves because the center cell in a sense can be thought of as zero space since not migrating leaves you there
		# still need to renormalize because only have the cumulative within 4 sigma
	normalized.kernel.1d <- kernel.1d/sum(kernel.1d)	# normalize the probabilities to sum to 1
	plot(1:cells.in.1D.kernel, normalized.kernel.1d)


########################################################################################################################
########################################################################################################################
#
#	for summing 2 distributions to create kurtosis:
#
# do the above again for a second distribution, sum the 1-D kernels and normalize
#
#	*** NOTE ***
#	WHEN SUMMING THE KERNELS, MAKE SURE TO ADD AFTER CENTERING AROUND 0
#
# dispersal kernel from 1 patch to surrounding patches
#	want it to be Gaussian and vary to having more LDD (long distance dispersal)

	if(two.kernels==TRUE){
		#second.dist.mean		# mean should stay at zero as dispersal is centered around natal patch
		#second.dist.sd		# this is sigma, one standard deviation, in meters

		# scale the landscape, and want to cut off at 4 sigma, so how many cells (in 1-D) are there within 4 sigma:
		second.units <- second.dist.sd/cell		# number of cells per one sigma
		second.four.sigma.units <- 4*second.units	# number of cells per four sigma IN ONE DIRECTION

		second.center.cell <- second.four.sigma.units + 1
		second.cells.in.1D.kernel <- second.four.sigma.units + second.four.sigma.units + 1
				# total cells going across the one-dimensional kernel are those one either side plus the central/natal one

		# make the 1-D kernel
		second.kernel.1d <- rep(NA, second.cells.in.1D.kernel)
		k <- 1
		for(i in -second.four.sigma.units:second.four.sigma.units){
			left.boundary <- (i-0.5)*cell
			right.boundary <- (i+0.5)*cell
			second.kernel.1d[k] <- pnorm(q=right.boundary, sd=second.dist.sd) - pnorm(q=left.boundary, sd=second.dist.sd)
			k <- k+1
		}

		# actually just take the first half and copy it to the second half
		# because the numbers slightly differ at the 12th decimal place otherwise.
		# might be slightly inaccurate, but will ensure accuracy down the line and a perfect mirror image
		second.kernel.1d <- c(second.kernel.1d[1:second.center.cell], second.kernel.1d[(second.center.cell-1):1])

			# correct to have the halves because the center cell in a sense can be thought of 
			#	as zero space since not migrating leaves you there
			# still need to renormalize because only have the cumulative within 4 sigma
		second.normalized.kernel.1d <- second.kernel.1d/sum(second.kernel.1d)	# normalize the probabilities to sum to 1

		diff.in.length <- abs(length(normalized.kernel.1d) - length(second.normalized.kernel.1d))
		each.end.diff <- diff.in.length/2
		# which is the shorter one:
		if((length(normalized.kernel.1d) - length(second.normalized.kernel.1d)) < 0){	
			# then first kernel is shorter, add to it's length
			second.shorter <- FALSE
			long.normalized.kernel.1d <- c(rep(0, each.end.diff), normalized.kernel.1d, rep(0, each.end.diff))
			plot(-second.four.sigma.units:second.four.sigma.units, second.normalized.kernel.1d, ylim=c(0,0.5), col="red")
			points(-second.four.sigma.units:second.four.sigma.units, long.normalized.kernel.1d, col="blue")
		}
		if((length(normalized.kernel.1d) - length(second.normalized.kernel.1d)) > 0){
			# then second kernel is shorter, add to it's length
			second.shorter <- TRUE
			second.normalized.kernel.1d <- c(rep(0, each.end.diff), second.normalized.kernel.1d, rep(0, each.end.diff))
			plot(-four.sigma.units:four.sigma.units, normalized.kernel.1d, ylim=c(0,0.5), col="red")
			points(-four.sigma.units:four.sigma.units, second.normalized.kernel.1d, col="blue")
		}

		prop.first.kernel <- 0.5
		prop.second.kernel <- 1 - prop.first.kernel
		summed.1d.kernels <- (long.normalized.kernel.1d * prop.first.kernel) + (second.normalized.kernel.1d * prop.second.kernel)

		# just for the plot, to know which x values to use
		if(second.shorter==FALSE){
			points(-second.four.sigma.units:second.four.sigma.units, summed.1d.kernels, pch=20, cex=0.75)
		}else{
			points(-four.sigma.units:four.sigma.units, summed.1d.kernels, pch=20, cex=0.75)
		}

		normalized.kernel.1d <- summed.1d.kernels
		normalized.kernel.1d <- kernel.1d/sum(kernel.1d)	# normalize the probabilities to sum to 1
		plot(1:cells.in.1D.kernel, normalized.kernel.1d)

		# multiply it by itself to create the 2-D
		horizontal.to.multiply <- matrix(NA, nrow=length(normalized.kernel.1d), ncol=length(normalized.kernel.1d))
		vertical.to.multiply <- matrix(NA, nrow=length(normalized.kernel.1d), ncol=length(normalized.kernel.1d))

		for(j in 1:length(normalized.kernel.1d)){
			horizontal.to.multiply[j,] <- normalized.kernel.1d
			vertical.to.multiply[,j] <- normalized.kernel.1d
		}

		multiplied.kernels <- horizontal.to.multiply * vertical.to.multiply


		# plot the multiplied matrix
		library(graphics)
		contour(multiplied.kernels, asp=1, nlevels= four.sigma.units)

		# find the cutoff value for distance travelled
		#  i.e. which contours don't make the full circle around because they travel farther than the central column/row?
		lower.cutoff <- multiplied.kernels[1, center.cell]
		multiplied.kernels[multiplied.kernels < lower.cutoff] <- 0
			# replace values lower than the cutoff with zero

		# plot the multiplied matrix that's been cut off to circular distances
		contour(multiplied.kernels, asp=1, nlevels= four.sigma.units)


		# restandardize so all sums to 1
		restandardized.multiplied.kernels <- multiplied.kernels/sum(multiplied.kernels)
		contour(restandardized.multiplied.kernels, asp=1, nlevels= four.sigma.units)
		disp.kernel <- restandardized.multiplied.kernels

		middle.of.kernel <- center.cell
			# ceiling(length(disp.kernel[,1])/2)	
			# works because there are an odd number for the length/width
		max.dist.include.natal <- middle.of.kernel	
			# the maximum number of cells an individual might migrate including 1 as staying in natal patch
		max.dist.exclude.natal <- middle.of.kernel - 1


		# TRY AND MAKE A ROUNDED KERNEL THAT STILL SUMS TO 1:
		for(i in 5:25){
			#print(i)
			if(sum(signif(disp.kernel, digits=i))==1){
				disp.kernel <- signif(disp.kernel, digits=i)
				print(i)
				break	# exit the loop
			}
		}
	}
	
#############################################################################################################################
#
#	NOW WE HAVE THE DISPERSAL KERNEL
#
#	NEED TO LINEARLY LIST IT IN DECREASING ORDER AND MATCH PATCH IDS TO IT
#
#############################################################################################################################

	one.dim.length <- max.dist.exclude.natal + max.dist.include.natal

	#dim(disp.kernel)

	xcoords <- (-max.dist.exclude.natal):max.dist.exclude.natal
	ycoords <- max.dist.exclude.natal:(-max.dist.exclude.natal)

	disp.kernel.xcoords <- matrix(rep(xcoords, one.dim.length), nrow= one.dim.length, byrow=TRUE)
	disp.kernel.ycoords <- matrix(rep(ycoords, one.dim.length), ncol= one.dim.length, byrow=FALSE)

	disp.array <- array(c(disp.kernel, disp.kernel.xcoords, disp.kernel.ycoords), dim=c(one.dim.length, one.dim.length,3))

	iterate.by <- seq(1, (one.dim.length^2), by= one.dim.length)

	disp.array.data.frame <- data.frame(rep(NA,length(disp.kernel)), rep(NA,length(disp.kernel)), rep(NA,length(disp.kernel)))
	names(disp.array.data.frame) <- c("dispersal.prob", "x.dist", "y.dist")


	j <- 0
	for(i in iterate.by){
		j <- j+1
		#print(i,j, i:(i+ (one.dim.length-1)))
		disp.array.data.frame$dispersal.prob[i:(i+ (one.dim.length-1))] <- disp.array[j,,1]
		disp.array.data.frame$x.dist[i:(i+ (one.dim.length-1))] <- disp.array[j,,2]
		disp.array.data.frame$y.dist[i:(i+ (one.dim.length-1))] <- disp.array[j,,3]
	}
	disp.array.data.frame <- disp.array.data.frame[disp.array.data.frame$dispersal.prob > 0 ,]

	sorted.disp.frame <- disp.array.data.frame[order(-disp.array.data.frame$dispersal.prob), ]

	array.sending.patch.coords <- sorted.disp.frame


	ghost.cell <- total.cells+1
	absorbing.cell <- ghost.cell+1

	num.patches.sending <- length(disp.array.data.frame[,1])

	conn.mat <- matrix(NA, nrow= total.cells, ncol= num.patches.sending)  # make a matrix to store the connectivity matrix
		# it's size is patch number by length of total cells possible to disperse into
	# make an identifying number for all patches, go down each column before moving on to the next column
	patch.number.ids <- matrix(0, nrow= cells.x, ncol= cells.y)
	for(i in 1: (cells.x * cells.y)){
		patch.number.ids[i] <- i
	}

	for(i in 1:total.cells){
		focal.patch <- i
		for(j in 1:num.patches.sending){
			skip <- FALSE
			if(j==1){
				conn.mat[i,j] <- focal.patch
			}else{
				if(focal.patch%%cells.x == 0){focal.row <- 20}else{focal.row <- focal.patch%%cells.x}
				patch.id.row <- (focal.row + sorted.disp.frame$y.dist[j])
				patch.id.col <- (ceiling(focal.patch/cells.x) + sorted.disp.frame$x.dist[j])
				if(patch.id.row <= 0 || patch.id.row > cells.x){
					conn.mat[i,j] <- absorbing.cell
					skip <- TRUE
					} # if send to a patch outside the landscape, make it the absorbing patch
				if(patch.id.col <= 0 || patch.id.col > cells.y){
					conn.mat[i,j] <- absorbing.cell
					skip <- TRUE
					}
				if(skip==FALSE) conn.mat[i,j] <- patch.number.ids[patch.id.row, patch.id.col]
			}
		}
	}

	# if making a breed window instead of a dispersal kernel, change the absorbing cell to the ghost.cell
	if(breed.window == TRUE){
		conn.mat[conn.mat== absorbing.cell] <- ghost.cell
	}
	
	kernel <- paste(c("{", paste(sorted.disp.frame$dispersal.prob, collapse=","), "}"), collapse=" ")


	# add on the extra rows for the ghost and absorbing patches
	conn.mat <- rbind(conn.mat, rep(ghost.cell, num.patches.sending), rep(absorbing.cell, num.patches.sending))

	# make it into a data frame so it prints out properly
	frame.conn.mat <- data.frame(conn.mat)

	write.table(frame.conn.mat, file="ConnMatrix.txt", sep=",", col.names=FALSE, row.names=FALSE)

	with.commas <- read.table("ConnMatrix.txt")
	with.commas$col1 <- "{"
	with.commas$col.last <- "}"
	final.connectivity.matrix <- cbind(with.commas$col1, paste(with.commas$V1), with.commas$col.last)
	if(breed.window == FALSE) write.table(final.connectivity.matrix, file="Dispersal_ConnMatrix.txt", col.names=FALSE, row.names=FALSE, quote=FALSE)
	if(breed.window == TRUE) write.table(final.connectivity.matrix, file="Breeding_ConnMatrix.txt", col.names=FALSE, row.names=FALSE, quote=FALSE)
	
	return(kernel)
}
