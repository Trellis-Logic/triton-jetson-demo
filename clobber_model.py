import onnx
from onnx import numpy_helper
import numpy as np
import sys

def corrupt_selected_layers(model_path, output_path, target_substrings, corruption_fn):
    model = onnx.load(model_path)
    count = 0
    for initializer in model.graph.initializer:
        if any(substr in initializer.name for substr in target_substrings):
            print(f"Corrupting: {initializer.name}")
            array = numpy_helper.to_array(initializer)
            corrupted_array = corruption_fn(array)
            new_tensor = numpy_helper.from_array(corrupted_array, initializer.name)
            initializer.CopyFrom(new_tensor)
            count += 1
    print(f"Corrupted {count} weight tensors.")
    onnx.save(model, output_path)

# Example corruption: add large noise
def heavy_noise(w):
    return w + np.random.normal(0, 10 * np.std(w), w.shape)

def clobber(input_path, output_path):
    model = onnx.load(path)
    for init in model.graph.initializer:
        print(init.name, init.dims)


def clobber(input, output):
    # Corrupt only block_4c
    corrupt_selected_layers(
        model_path=input,
        output_path=output,
        target_substrings=["block_4c"],
        corruption_fn=heavy_noise
)

if __name__ == "__main__":
    clobber(sys.argv[1], sys.argv[1] +  ".clobbered.onnx")
