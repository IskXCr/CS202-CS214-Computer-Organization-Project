# VGA Text Mode Driver

## Introduction

Please see `src/IO/output/VGA_drv` (a separated module that can be used individually).

Supports `80*30` text resolution using `CP885.F16` as the character set.

## Specification

Buffer `80*30`, write bitwidth `32` bit, byte-order little-endian.

Internally uses a font memory that initializes from `coe/CP885.F16.coe`. A font converter is provided in the utility folder.