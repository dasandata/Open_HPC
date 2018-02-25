help(
[[
This module provides the environment for NVIDIA CUDA.
CUDA tools and libraries must be in your path in order
to take advantage of NVIDIA GPU compute capabilities.
{version}
]])


whatis("Name: CUDA")
whatis("Version: {version}")
whatis("Category: library, runtime support")
whatis("Description: NVIDIA CUDA libraries and tools for GPU acceleration")
whatis("URL: https://developer.nvidia.com/cuda-downloads")


family("cuda")


local version = "{version}"
local base    = "/usr/local/cuda-{version}"


setenv("CUDA_HOME", base)
setenv("CUDA_VERSION", "{version}")

prepend_path("PATH",            pathJoin(base, "bin"))
prepend_path("INCLUDE",         pathJoin(base, "include"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib64"))

-- Having the CUDA SDK samples available can be useful.
prepend_path("PATH",            pathJoin(base, 'samples-bin'))

-- Push the 64-bit NVIDIA libraries into the front of the LD path.
-- Necessary to fix applications which stupidly look in /usr/lib/ first.
prepend_path("LD_LIBRARY_PATH", "/usr/lib64/nvidia")


--
-- No man files included with CUDA
--
