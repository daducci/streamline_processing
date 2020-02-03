# Streamline processing toolbox



## Installation

Open the system shell, go to the folder where you downloaded this repository and run:

```bash
pip install .
```

The library is now available in your Python interpreter and can be imported as:

```python
import streamline_processing
```

## Usage

To e.g. smooth the streamlines ina tractogram using splines, do the following:

```python
import streamline_processing
streamline_processing.spline_smoothing( "mystreamlines.trk", "mystreamlines_smooth.trk", 0.25, 1.0, True )
```

