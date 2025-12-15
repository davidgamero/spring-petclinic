package kubernetes.containers.images

# Deny containers that use images not from the allowed list
deny[msg] {
    container := input.review.object.spec.containers[_]
    image := container.image
    not is_microsoft_image(image)
    msg := sprintf("Image '%s' is not from an allowed Microsoft registry.", [image])
}

# Optional: also check initContainers
deny[msg] {
    container := input.review.object.spec.initContainers[_]
    image := container.image
    not is_microsoft_image(image)
    msg := sprintf("Image '%s' is not from an allowed Microsoft registry.", [image])
}

# Define what constitutes a "Microsoft image" by checking prefixes
is_microsoft_image(image) {
    microsoft_registries := [
        "mcr.microsoft.com/",
        "microsoft/"
        # Add other specific Microsoft registries as needed
    ]
    some i
    startswith(image, microsoft_registries[i])
}
