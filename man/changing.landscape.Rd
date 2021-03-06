% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/SelectionLandscape.R
\name{changing.landscape}
\alias{changing.landscape}
\title{Combine two landscapes of optimal phenotypic values to create a change in steepness}
\usage{
changing.landscape(horizontal.patches, vertical.patches, split.landscape,
  scale.to1 = 1, scale.to2 = 2, step.width1 = NULL, step.width2 = NULL,
  range1 = NULL, range2 = NULL, sill1 = NULL, sill2 = NULL,
  magnitude1 = NULL, magnitude2 = NULL, directionality1 = NULL,
  directionality2 = NULL, nearest.obs1 = NULL, nearest.obs2 = NULL,
  cylinder = FALSE)
}
\arguments{
\item{horizontal.patches}{Number of patches (columns) in the horizontal, x direction.}

\item{vertical.patches}{Number of patches (rows) in the vertical, y direction.}

\item{split.landscape}{Number of patches (columns) in the horizontal, x direction that the first landscape occupies. The second landscape will cover the remaining landscape.}

\item{scale.to1}{Value to scale down the magnitude of change in optima over the first landscape. Default is 1, which scales the total change to approximately -1 to 1 across the first landscape, whereas, e.g. a value of 5 allows a higher degree of change across the landscape, approximately -5 to 5.}

\item{scale.to2}{Value to scale down the magnitude of change in optima over the second landscape. Default is 2, which scales the total change to approximately 1 to 3 across the remainder of the landscape (or if the default for scale.to1 is changed, this minimum adjusts automatically to the maximum of that first scale's range).}

\item{step.width1}{The number of patches that horizontally make up the width of "steps" of equal optimal phenotype to create the first landscape, if using the step model. At most can equal the number of vertical columns in the first landscape to create a uniform landscape, or at minimum can equal 1 for the landscape to change every single column of patches. This number must equally divide into the total number of horizontal patches per landscape.}

\item{step.width2}{The number of patches that horizontally make up the width of "steps" of equal optimal phenotype to create the second landscape.}

\item{range1}{If the first landscape is patchy, use this parameter. The distance at which covariance between patches goes to zero, i.e. how similar is each grain to the next. A larger value makes the landscape smoother.}

\item{range2}{If the second landscape is patchy, use this parameter. See range1 for description.}

\item{sill1}{If the first landscape is patchy, use this parameter. The scale of the variance. See ?vgm, this is the sill of the variogram model component. A larger value makes the landscape more patchy. Default value is 1.}

\item{sill2}{If the second landscape is patchy, use this parameter. See sill1 for description.}

\item{magnitude1}{If the first landscape is patchy, use this parameter. The first beta parameter for simple kriging in the gstat function. Default is zero.}

\item{magnitude2}{If the second landscape is patchy, use this parameter. See magnitude1 for description.}

\item{directionality1}{If the first landscape is patchy, use this parameter. The second beta parameter for simple kriging in the gstat function. Default is 1. Larger values smooth the change in the direction of change.}

\item{directionality2}{If the second landscape is patchy, use this parameter. See directionality1 for description.}

\item{nearest.obs1}{If the first landscape is patchy, use this parameter. Used for local kriging, see ?gstat: the number of nearest observations that should be used for a kriging prediction or simulation. Default is 20.}

\item{nearest.obs2}{If the second landscape is patchy, use this parameter. See nearest.obs1 for description.}

\item{cylinder}{If the landscape is meant to be simulated as a cylinder, where the horizontal edges match up for individuals to disperse across, this should be set to true. This will halve the vertical length and mirror the landscape so that to horizontal edges match where they meet. Currently this capability is not yet coded in.}
}
\value{
Returns the value of the first column of patches at the leftmost end of the landscape. Also prints to a file the matrix of values for the landscape, to be uses as "selection_local_optima" in Nemo, and additionally visualizes the landscape.
}
\description{
Create the landscape of optimal phenotypic values over which the patches will exist from two previously created landscapes of different steepness for the gradient.
}
\examples{
changing.landscape(horizontal.patches=500,vertical.patches=10,split.landscape=250,scale.to1=10,scale.to2=10,step.width1=25, step.width2=1)

changing.landscape(horizontal.patches=50,vertical.patches=20,split.landscape=25,scale.to1=20,scale.to2=10,range1=1, range2=1)
}
\author{
Kimberly J Gilbert
}

