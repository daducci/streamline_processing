from distutils.core import setup, Extension
from Cython.Distutils import build_ext
import numpy


ext = Extension(
    name='streamline_processing',
    sources=['streamline_processing.pyx'],
    include_dirs=[numpy.get_include()],
    extra_compile_args=['-w', '-std=c++11'],
    extra_link_args=[],
    language='c++',
)

setup(
    name='streamline_processing',
    description='Algorithms to process/manipulate streamlines in a tractogram',
    author='Alessandro Daducci',
    author_email='alessandro.daducci@univr.it',
    url='https://github.com/daducci/streamline_processing',
    version='1.0',
    cmdclass = {'build_ext':build_ext},
    ext_modules = [ ext ],
)
