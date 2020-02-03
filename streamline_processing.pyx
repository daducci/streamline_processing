#!python
# cython: boundscheck=False, wraparound=False, profile=False
import cython
import numpy as np
cimport numpy as np
import nibabel
from amico.progressbar import ProgressBar


# Interface to actual C code
cdef extern from "spline_smoothing_c.cpp":
    int do_spline_smoothing(
        float* ptr_npaFiberI, int nP, float* ptr_npaFiberO, float ratio, float segment_len
    ) nogil


cpdef spline_smoothing( trk_filename_in, trk_filename_out, control_point_ratio = 0.25, segment_len = 1.0, verbose = False ) :
    """Smooth each streamline in the input tractogram using Catmull-Rom splines.
       More info at http://algorithmist.net/docs/catmullrom.pdf.

    Parameters
    ----------
    trk_filename_in : string
        Path to the .trk file containing the tractogram to process.

    trk_filename_out : string
        Path to the .trk where to store the filtered tractogram.

    control_point_ratio : float
        Percent of control points to use in the interpolating spline (default : 0.25).

    segment_len : float
        Sampling resolution of the final streamline after interpolation (default : 1.0).

    verbose : boolean
        Print information and progess (default : False).
    """

    try :
        trk_fibers, trk_hdr = nibabel.trackvis.read( trk_filename_in, as_generator=True )
    except :
        raise IOError( 'Track file not found' )

    if control_point_ratio < 0 or control_point_ratio > 1 :
        raise ValueError( "'control_point_ratio' parameter must be in [0..1]" )

    if verbose :
        print '* input tractogram :'
        print '\t- %s' % trk_filename_in
        print '\t- %d fibers' % trk_hdr['n_count']
        print '\t- %d x %d x %d' % ( trk_hdr['dim'][0], trk_hdr['dim'][1], trk_hdr['dim'][2] )
        print '\t- %.4f x %.4f x %.4f' % ( trk_hdr['voxel_size'][0], trk_hdr['voxel_size'][1], trk_hdr['voxel_size'][2] )
        print '* output tractogram :'
        print '\t- %s' % trk_filename_out
        print '\t- control points : %.1f%%' % (control_point_ratio*100.0)
        print '\t- segment length : %.2f' % segment_len

    # create the structure for the input and output polyline
    cdef float [:, ::1] npaFiberI
    cdef float* ptr_npaFiberI
    cdef float [:, ::1] npaFiberO = np.ascontiguousarray( np.zeros( (3*10000,1) ).astype(np.float32) )
    cdef float* ptr_npaFiberO = &npaFiberO[0,0]

    trk_fiber_out = []
    if verbose :
        progress = ProgressBar( n=trk_hdr['n_count'], prefix="", erase=True )
    for f in trk_fibers :
        streamline = np.ascontiguousarray( f[0].copy() )
        npaFiberI = streamline
        ptr_npaFiberI = &npaFiberI[0,0]

        n = do_spline_smoothing( ptr_npaFiberI, f[0].shape[0], ptr_npaFiberO, control_point_ratio, segment_len )
        streamline = np.reshape( npaFiberO[:3*n].copy(), (n,3) )
        trk_fiber_out.append( (streamline, None, f[2]) )
        if verbose :
            progress.update()

    trk_hdr_out = trk_hdr.copy()
    trk_hdr_out['n_scalars'] = 0
    nibabel.trackvis.write( trk_filename_out, trk_fiber_out, trk_hdr_out ) # after resampling, scalars have no meaning
