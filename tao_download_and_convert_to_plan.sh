#!/bin/bash
set -e

source $(dirname $0)/environment.sh

mkdir -p "$BASE_DIR"

# --- Check prerequisites ---
function check_requirements() {
    echo "🔍 Checking requirements..."

    if ! command -v trtexec >/dev/null 2>&1; then
        echo "❌ trtexec not found in PATH."
        exit 1
    fi

    if ! command -v ngc >/dev/null 2>&1; then
        echo "❌ ngc CLI not found in PATH."
        exit 1
    fi

    if ! python3 -c "import onnxruntime" >/dev/null 2>&1; then
        echo "❌ Python module 'onnxruntime' not installed."
        echo "   Install with: pip install onnxruntime"
        exit 1
    fi

    echo "✅ All requirements found."
}

# --- Generate config.pbtxt based on real ONNX metadata ---
function create_config_pbtxt() {
    local model_dir="$1"
    local onnx_file="$2"

    local config="$model_dir/config.pbtxt"

    python3 - "$onnx_file" "$config" <<'EOF'
import sys
import onnxruntime as ort

onnx_path, config_path = sys.argv[1:3]
session = ort.InferenceSession(onnx_path)

inputs = session.get_inputs()
outputs = session.get_outputs()

def dtype_to_triton(dtype):
    return {
        'tensor(float)': 'TYPE_FP32',
        'tensor(int64)': 'TYPE_INT64'
    }.get(dtype, 'TYPE_UNKNOWN')

with open(config_path, 'w') as f:
    f.write('name: "peoplenet"\n')
    f.write('platform: "tensorrt_plan"\n')
    f.write('max_batch_size: 1\n\n')

    f.write("input [\n")
    for i, inp in enumerate(inputs):
        dtype = dtype_to_triton(inp.type)
        dims = ", ".join(str(d) for d in inp.shape[1:])  # skip batch
        f.write(f"  {{\n    name: \"{inp.name}\"\n    data_type: {dtype}\n    format: FORMAT_NCHW\n    dims: [{dims}]\n  }}")
        f.write(",\n" if i < len(inputs) - 1 else "\n")
    f.write("]\n\n")

    f.write("output [\n")
    for i, out in enumerate(outputs):
        dtype = dtype_to_triton(out.type)
        dims = ", ".join(str(d) for d in out.shape[1:])  # skip batch
        f.write(f"  {{\n    name: \"{out.name}\"\n    data_type: {dtype}\n    dims: [{dims}]\n  }}")
        f.write(",\n" if i < len(outputs) - 1 else "\n")
    f.write("]\n")
EOF
}

# --- Main loop ---
check_requirements

for version in "${!versions[@]}"; do
    ngc_version="${versions[$version]}"
    dest_dir="${BASE_DIR}/${version}"

    echo "📥 Downloading PeopleNet $ngc_version to $dest_dir"
    mkdir -p "$dest_dir"
    ngc registry model download-version "nvidia/tao/peoplenet:${ngc_version}" \
        --dest "$dest_dir"

    onnx_file=$(find "$dest_dir" -name "*.onnx" | head -n1)
    if [ -z "$onnx_file" ]; then
        echo "❌ No ONNX file found for version $version"
        exit 1
    fi

    echo "⚙️ Converting to TensorRT engine..."
    trtexec --onnx="$onnx_file" --saveEngine="$dest_dir/model.plan" --fp16

    echo "📝 Generating config.pbtxt at $dest_dir..."
    create_config_pbtxt "$dest_dir" "$onnx_file"

    cp $(dirname $onnx_file)/labels.txt $dest_dir

    echo "✅ Completed version $version"
done
