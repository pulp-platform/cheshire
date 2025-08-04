# FESVR support on chesire

# Getting Started 

## Things needed : 
 - fesvr
 -  pk

### RISC-V Frontend Server : fesvr
Install fesvr : `` git clone https://github.com/riscv-software-src/riscv-isa-sim.git`` 

Make sure that **USE_CONTEXT** is not defined in *fesvr/context.h*, the **line 10** can be commented.

You should also had ``fesvr_install_shared_lib = yes`` in *fesvr/fesvr.mk.in* it will install a shared lib, the static one will not work with sim tools.
Remember the path of the installation, it’s needed to modify **Cheshire.mk** and **target/sim/vXXX/start.cheshire_soc.XXX** and update the path.
```
mkdir build install
cd build
../configure --prefix=`realpath ../install/` --without-boost-regex
make
make install
```

### Cheshire
Nothing change for the installation, 2 new script should be generated, to add fesvr usage when running vsim or vcs, make sure that you have given the right path to libfesvr.so in the previous step !
Then you can run ``make all`` as usual.

### RISC-V Proxy kernel : pk
You can git clone pk from my fork, and follow the installation from the readme, don’t forget to use -with_dts=path/to/cheshire.dts when doing the ../configure command. Like this

```
mkdir build install
cd build
../configure --prefix=`realpath ../install/` --host=riscv64-unknown-elf --with-dts=`realpath ../../cheshire/sw/boot/cheshire_spm.dts`
make
make install
```
Keep in mind the path to your pk installation, it will be used in cheshire simulation


## Simulation
To run a simulation using fesvr dtm, with questa, do like this in *./target/sim/vsim*: 
```
set PK /path/riscv-pk/install/pk
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

# How it works
## Strucural change
![Cheshire fesvr supported block diagram](./fesvr_support_cheshire.svg)

## Behavior of the simulation
There is several steps in the simulation, that can be observed by looking at the wave of dmi signals.

First, pk is preloaded using serial link, this reduce the simulation time by using the burst mode of serial link to preload pk faster.

Then, the frontend server (FESVR) take the lead, a dtm object is created, it will resume the core and start the proxy-kernel (pk).

Once pk is booted, the FESVR will preload the binary using the debug module and runs it. When it's finished, the fesvr return an exitcode, allowing to know if everything went well or not.


# Changes done & Explanation
## DPI
2 DPI have been added, they are inspired by the DPI inside of *SimDTM.cc* and an upper class of *dtm_t* have been created.

**preload_aware_dtm**: this upper class of dtm_t does change the *is_address_preloaded* function (from htif_f), this allow to preload the first binary that will be preloaded by the dtm object, in our case, pk.\
This makes the simulation faster because when a binary is preloaded by the dtm, it uses dmi signals to communicate with the debug module, and only 64bits of data are transmitted. So it takes 24 instructions to write 64bits of the elf file in the memory of the SoC, as pk is a big program, around 90kB, it can be long to preload it (3-4min in real time when simulating)

**debug_new**: it return a void* (chandle in sv) and takes 2 paths as arguments.\
This DPI create a new dtm class, with the pk as a kernel and the binary that will be executed. It will be called by the testbench.

**debug_tick**: it return an integer and takes a dtm object and dmi signals as arguments\
This DPI call the *tick* function from dtm, this allow to get the value for the dmi request and 2 handshake signals, depending on dmi response and 2 corresponding handshake signals.\
Overall this DPI allow to assign values to dmi signals, to ensure a proper communication with the debug module. It will be called in the VIP at every clockcycle.

### Useful information about dtm
When a dtm class is created, everything take place at the initialisation.\
An sub-htif object is initialised with the arguments coming from dtm arg. Then a function is called, *start_host_thread*, it will make a context switch and call the *producer_thread* function. That will enable the debugger of Cheshire and call the *run* function from htif.\
This last function, preload the binary (if needed) and resume the core to run the binary. This function as an internal loop, until the binary as finished running and then return the exitcode.

## VIP
Inside the VIP, a few changes have been done, the code from SimDTM has been reused with a few changes.
The way that the reset signal is handled as changed because it was not working for me and a *dmi_rst_ni* signal have been added.
A chandle have been added, to comply with the new feature of the DPI. It will be initialised thanks to the *fesvr_set* task.
Tasks have been created to handle the *dmi_rst_ni* signals.

**Be careful, when running a testbench,** you must set fesvr before starting it, so call the task *fesvr_set* before *fesvr_start*.

The task *fesvr_wait_for_exit* will loop until sim_exit has changed, so when the binary is finished.
It consider that the program should return 1, to say that everything went fine. In case of a problem, it should print the exitcode.

The I/O have also been changed to add dmi signals when FESVR_DTM is defined, so when the fesvr compile script is used.

## SoC
Inside of the SoC, dmi signals have been added as I/O, they do replace the dmi signals coming from the dmi_jtag module, that convert information coming from jtag to the debug module. This means that **when using fesvr, you can not use jtag.**\
About the *dmi_rst_ni* signal, it is only used to reset a FIFO that contains the dmi signals inside of the debug module.

## Testbench
Few changes have been done to handle and run fesvr. As you can see, the proxy kernel is preloaded using serial link.\
Then a chandle for dtm_t is created and it is started by setting the dmi reset to 1, starting to use the dpi, debug_tick at every clock cycle. the task coming from vip will wait for the end and the simulation will finish.

# Possible upgrade
### Running several app in a single simulation
To do this, changes must be done to the FESVR library.
There is a function in *htif.cc*, called *run*, that loop on a value of the object called **stopped**. This value is set at the initialisation of the object to *false* and when run is finished, it's set to *true*.
There is no other function changing this value. So this is the first modification that would be needed if you want to run a new binary with the same object.
x
Also, inside *dtm.cc*, there is a function called *producer_thread*. It is called at the end of the initialisation of the dtm class and used to connect the fesvr to the debug module and to run the program (with *htif_t::run*). The thing is that at the end, there is a loop with only nop, so this function never really finish. The end of the simulation is endled by the testbench thanks to the exitcode comming from *htif_t::run*.

An other solution, would be to use the chandle feature, but there is no clean way to close the connection between the debug module and dtm, a proper destructor might be needed...
It would have to make sure that everything is finished and get back to running pk, that will poll htif registers.
This could allow to create a 1st dtm class, with pk and binary 1, then run it and destruct it properly, than you could create a 2nd dtm class, with 

# Others
The fesvr implementation inside of the CVA6 is a bit old and has not been update or evolved. It was inspired by the work done in Chipyard Framework. Inside this framework repository, we can find updated documentations with useful information that can come in hand to understand how it works and also to add features (TSI support or GDB - OpenOCD - JTAG support).

[Chipyard - Boot process](https://chipyard.readthedocs.io/en/latest/Customization/Boot-Process.html#)

[Chipyard - Chip communication](https://chipyard.readthedocs.io/en/latest/Advanced-Concepts/Chip-Communication.html)