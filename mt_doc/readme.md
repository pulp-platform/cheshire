# FESVR support on chesire

# Getting Started 

## Things needed : 
 - fesvr
 -  pk

They are inside *sw/deps*, you will just need to run ``git submodule update --init --recursive`` to download them.

### Cheshire
Nothing change for the installation, 2 new script should be generated, to add fesvr support when running vsim or vcs. 
Then you can run ``make all`` as usual.

### RISC-V Frontend Server : fesvr
FESVR should have been built when running the ``make all``.\
Make sure that fesvr is correctly build, you should see in *sw/deps*, the lib in *riscv-isa-sim/install/lib* and 3 directories in *riscv-isa-sim/install/include*

To build the fesvr, you can run make build-fesvr from cheshire directory.\
It will create a shared library, that will be used by simulation tools and DPI.


### RISC-V Proxy kernel : pk 
pk should have been built when running the ``make all``.\
Keep in mind the path to your pk installation, it might be used in cheshire simulation.

To build pk, you can do as following : 
```
mkdir build install
cd build
../configure --prefix=`realpath ../install/` --host=riscv64-unknown-elf --with-dts=`realpath ../../cheshire/sw/boot/cheshire.dtsi`
make
make install
```


## Simulation
To run a simulation using fesvr dtm, with questa, you have two choice, to run it with pk or not. \
The proxy kernel (pk) does bring syscall support and more, allowing to run program with standard lib and I/O, like *printf* for example.\
Going without pk can be useful if you want to run binary from **riscv-tests**, such as benchmarks or isa tests, are they are made to easily run bare-metal with fesvr.\
The choice of using comes to setting **PK** or not, when setting the parameter for the simulation in your tool.

Here is an example of running a binary over pk:
```
set PK /path/sw/deps/riscv-pk/install/pk
set BINARY /path/sw/apps/helloworld.riscv
set BOOTMODE 0
set PRELMODE 1

# Compile design WITH fesvr
source compile.cheshire_soc_fesvr.tcl

# Start and run simulation
source start.cheshire_soc.tcl
run -all
```
If you want to run an other simulation with a new app, you just have to set **BINARY** with an other value and run again the **start.cheshire_soc** script.

Giving the right compilation script, will make cheshire RTL compiled with fesvr support, you should run the one with **_fesvr** at the end, like in the example.

# How it works

## Behavior of the simulation
There is several steps in the simulation, that can be observed by looking at the wave of dmi signals.

### If using the proxy-kernel 
First, pk is preloaded using serial link, this reduce the simulation time by using the burst mode of serial link to preload pk faster.

Then, the frontend server (FESVR) take the lead, a dtm object is created, it will resume the core and start the proxy-kernel (pk).

Once pk is booted, the FESVR will preload the binary using the debug module and runs it. When it's finished, the fesvr return an exitcode, allowing to know if everything went well or not.

The exitcode is handled by the testbench, to finish the simulation.

### Without the proxy-kernel
First, the binary is preloaded using serial link, like when using pk, to make the simulatio faster.

Then, the frontend server (FESVR) take the lead, a dtm object is created, it will resume the core and start the binary. When it's finished, the fesvr return an exitcode, allowing to know if everything went well or not.

The exitcode is handled by the testbench, to finish the simulation.

## Strucural change
![Cheshire fesvr supported block diagram](./fesvr_support_cheshire.svg)

All the changes happens when compiled with the FESVR parameter.\
I/O have been added for the dmi signals, to connect the front-end server with the debug module of Cheshire.\
The architecture of SimDTM as been taken and his now directly in the VIP. Which will take care of calling the DPI to communicate.

# Changes done & Explanation
## DPI
3 DPI have been added, they are inspired by the DPI inside of *SimDTM.cc* and an upper class of *dtm_t* have been created.

**preload_aware_dtm**: this upper class of dtm_t does change the *is_address_preloaded* function (from htif_f), this allow to preload the first binary that will be preloaded by the dtm object, in our case, pk.\
This makes the simulation faster because when a binary is preloaded by the dtm, it uses dmi signals to communicate with the debug module, and only 64bits of data are transmitted. So it takes 24 instructions to write 64bits of the elf file in the memory of the SoC, as pk is a big program, around 90kB, it can be long to preload it (3-4min in real time when simulating)

**debug_new_pk**: it return a void* (chandle in sv) and takes 2 paths as arguments.\
This DPI create a new dtm class, with the pk as a kernel and the binary that will be executed. It will be called by the testbench.

**debug_new**: it return a void* (chandle in sv) and takes a path as argument.\
This DPI create a new dtm class, with the binary that will be executed. It will be called by the testbench.\
So the difference with *debug_new_pk* is that there is no kernel used in this one, allowing to run application 

**debug_tick**: it return an integer and takes a dtm object and dmi signals as arguments\
This DPI call the *tick* function from dtm, this allow to get the value for the dmi request and 2 handshake signals, depending on dmi response and 2 corresponding handshake signals.\
Overall this DPI allow to assign values to dmi signals, to ensure a proper communication with the debug module. It will be called in the VIP at every clockcycle.

### Useful information about dtm
When a dtm class is created, everything take place at the initialisation.\
A sub-htif object is initialised with the arguments coming from dtm arg. Then a function is called, *start_host_thread*, it will make a context switch and call the *producer_thread* function. That will enable the debugger of Cheshire and call the *run* function from htif.\
This last function, preload the binary (if needed) and resume the core to run the binary. This function as an internal loop, until the binary as finished running and then return the exitcode.

## VIP
Inside the VIP, a few changes have been done, the code from SimDTM has been reused with a few changes.
The way that the reset signal is handled as changed because it was not working for me and a *dmi_rst_ni* signal have been added.
A chandle have been added, to comply with the new feature of the DPI. It will be initialised thanks to the *fesvr_set* task.\
Tasks have been created to handle the *dmi_rst_ni* signals.

As you can see, the full code of SimDTM have been copied into the VIP, it's easier to do this way, as SimDTM has never been updated since it's in the CVA6

**Be careful, when running a testbench,** you must set fesvr before starting it, so call the task *fesvr_set* before *fesvr_start*.

The task *fesvr_wait_for_exit* will loop until the bit 0 of sim_exit is set to 1, so when the binary is finished.\
A shift is done on sim_exit to get the exit code of the program. Which will be used to know if the simulation was succesful or not.

The I/O have also been changed to add dmi signals when FESVR_DTM is defined, so when the fesvr compile script is used.

## SoC
Inside of the SoC, dmi signals have been added as I/O, they do replace the dmi signals coming from the dmi_jtag module, that convert information coming from jtag to the debug module. This means that **when using fesvr, you can not use jtag.**\
About the *dmi_rst_ni* signal, it is only used to reset a FIFO that contains the dmi signals inside of the debug module.

## Testbench
Few changes have been done to handle and run fesvr. As you can see, the proxy kernel is preloaded using serial link.\
Then a chandle for dtm_t is created and it is started by setting the dmi reset to 1, starting to use the dpi, debug_tick at every clock cycle. the task coming from vip will wait for the end and the simulation will finish.

## RISC-V Frontend Server : fesvr
### Problems encountered when installing it
Two main problems happen when installing the fesvr like explained in it documentation : 
- No shared lib created -> needed by simulation tools
- wrong ucontext used   -> assert error when running fesvr

To solve the first problem, the shared lib can simply be created by adding ``fesvr_install_shared_lib = yes`` in *fesvr/fesvr.mk.in* but this would require to change the code, it can also be done by running a command in the terminal to create it directly than copying it in the *install/lib* directory.

The second problem is caused by **USE_CONTEXT** being defined in *fesvr/context.h*.\
This is due to **\_\_GLIBC\_\_** being defined because, when compiling context.cc, the flag ``-I/usr/include`` is used. Giving the full directory which will cause **\_\_GLIBC\_\_** to be defined. But context.cc does not needs it, in fact, not a single file compiled does need it (for fesvr library), so we can bypass this problem by not using this flag when compiling our own fesvr shared library.

A script allow to compile the shared lib, making it easier.

# Possible upgrade
### Running several app in a single simulation
To do this, changes must be done to the FESVR library.
There is a function in *htif.cc*, called *run*, that loop on a value of the object called **stopped**. This value is set at the initialisation of the object to *false* and when run is finished, it's set to *true*.
There is no other function changing this value. So this is the first modification that would be needed if you want to run a new binary with the same object.

Also, inside *dtm.cc*, there is a function called *producer_thread*. It is called at the end of the initialisation of the dtm class and used to connect the fesvr to the debug module and to run the program (with *htif_t::run*). The thing is that at the end, there is a loop with only nop, so this function never really finish. The end of the simulation is endled by the testbench thanks to the exitcode comming from *htif_t::run*.

An other solution, would be to use the chandle feature, but there is no clean way to close the connection between the debug module and dtm, a proper destructor might be needed...
It would have to make sure that everything is finished and get back to running pk, that will poll htif registers.
This could allow to create a 1st dtm class, with pk and binary 1, then run it and destruct it properly, than you could create a 2nd dtm class, with 

# Others
The fesvr implementation inside of the CVA6 is a bit old and has not been update or evolved. It was inspired by the work done in Chipyard Framework. Inside this framework repository, we can find updated documentations with useful information that can come in hand to understand how it works and also to add features (TSI support or GDB - OpenOCD - JTAG support).

[Chipyard - Boot process](https://chipyard.readthedocs.io/en/latest/Customization/Boot-Process.html#)

[Chipyard - Chip communication](https://chipyard.readthedocs.io/en/latest/Advanced-Concepts/Chip-Communication.html)