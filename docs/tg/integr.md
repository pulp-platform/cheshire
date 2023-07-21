# SoC Integration

Cheshire is designed to be *highly configurable* and provide host and interconnect infrastructure for systems on various scales. Examples of SoCs integrating Cheshire are:

- [Iguana](https://github.com/pulp-platform/iguana), an minimal end-to-end open-source Linux-capable SoC built with open tools.
- [Carfield](https://github.com/pulp-platform/carfield), a mixed-criticality SoC targeting the automotive domain.

## Using Cheshire In Your Project

As for internal targets, Cheshire *must be built* before use in external projects. We aim to simplify this as much as possible with a portable *make fragment*.

If you use GNU Make to build your project and Bender to handle dependencies, you can include the Cheshire build system into your own Makefile with:

```make
include $(shell bender path cheshire)/cheshire.mk
```

All of Cheshire's build targets are now available with the prefix `chs-`. You can leverage this to ensure your Cheshire build is up to date and rebuild hardware and software whenever necessary. You can change the default value of any build parameter, replace source files to adapt Cheshire, or reuse parts of its build system, such as the software stack or the register and ROM generators.

## Instantiating Cheshire

