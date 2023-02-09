# RegFile
## Name
Minjun Kwak
## Description of Design
My Regfile module is made up of the submodules: 32-bit registers, decoders, and tri-state buffers. The 32 32-bit registers are constructed using genvar loops, and each 32-bit register is itself created using a genvar loop to construct 32 1-bit DFFs. Each register's data input port is connected to the regfile module's data_writeReg input, but the write enables of 31 of the registers are turned off using a decoder on the ctrl_writeReg input. Each register's out port is connected to two separate tri-state buffers which eventually connect to the two read ports of the regfile. The tri-state buffers allow all outputs to be connected to the same read port, as all but one of the outputs will be a high impedance z, and the two registers we want to read from will be allowed to connect to the read port using two decoders at the ctrl_readReg inputs.
## Bugs
No bugs detected.