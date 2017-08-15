Setting up Jenkins for Kwiver
=============================

Starting a Docker Instance
--------------------------

First, visit https://hub.docker.com/_/jenkins/ for a docker image containing Jenkins. The listed instructions won't quite work for Kwiver, however. Instead, we need to create a file named "Dockerfile" with the following contents:

    FROM jenkins

	USER root

	RUN apt-get update && apt-get install -y build-essential libx11-dev cmake
	
What this allows is the creation of a new image with several libraries and tools preinstalled. I recommend . To create the image, run the following command from the directory containing your Dockerfile:

    docker build -t jenkins_image .
	
You can change "jenkins_image" to whatever you want the name of the new image to be. Now that the new image is built, you can create a container, which is an individual docker instance. To create a container from your image, use the following command:

    docker run -p 8080:8080 -p 50000:50000 -v /var/local_jenkins_home:/var/jenkins_home --restart=unless-stopped --name jenkins_kwiver jenkins_image
	
The "-p 8080:8080 -p 50000:50000" means you will forward the 8080 and 50000 ports, which are necessary for jenkins to work. "-v /var/local_jenkins_home:/var/jenkins_home" creates a volume. The /var/local_jenkins_home directory on the host machine will now correspond to the /var/jenkins_home directory on the image. This will allow you to access jenkins data without needing to use docker. "--restart=unless-stopped" sets a restart policy. If your machine turns off or the docker container crashes for any reason, it will automatically restart the instance, unless you manually stop the container. If you're using your own process management tools, this argument can and should be skipped in favor of using that tool. "--name jenkins_kwiver" is used to set the name of your container. You can pick whatever name you wish; otherwise, if the parameter is not used, it'll pick a randomly generated one like "backstabbing_northcutt" The last parameter, "jenkins_image", tells it to use the image we created with the Dockerfile. If you used a different name, make sure to adjust this parameter appropriately.

The docker image will be created and started. Lots of log information will appear as the image is being create: it'll eventually hang on the line "--> setting agent port for jnlp... done". At that point it's ready for use. Go to http://localhost:8080 and Jenkins will appear. At this point, you can do update to the latest Jenkins version, create an admin account, and so forth. Most of the setup process is straight forward, but you can also check documentation at Jenkins website (https://jenkins.io/) if you would like more guidance. Recent versions of Jenkins require an initial admin password: if you're updated and need the password, you can access it with the following command:

    docker exec jenkins_kwiver cat /var/jenkins_home/secrets/initialAdminPassword

You now have a docker instance ready for use. If you ever need to start or stop, use the command "docker start jenkins_kwiver" or "docker stop jenkins_kwiver" respectively.

Connecting Jenkins to Github
----------------------------

The next step is to get Jenkins to connect to Github so it can do nightly and experimental builds. First, we'll do a nightly build. Click "New Item" on the toolbar on the left side of the screen. It'll allow you to name the project and choose a series of project types. Name the project whatever you wish (I chose KwiverLinuxNightly) and choose "Freestyle Project", which will give you a blank canvas to work with.

You're now in the configuration page. You want to make the following changes:

- Check "Github project" and fill in the project URL (for example https://github.com/kitware/kwiver/)
- Select "Git" under "Source Code Management" and fill in the same project URL. You can also change the branch here if you don't want to work on master.
- Under "Build Triggers" select "Build Periodically". This uses a modified cron syntax; you can get more information if you click the question mark next to the textbox. There are also several shortcuts; I used the shortcut "@midnight" which will build it every night, at some consistent time between 12:00-2:59am. Keep in mind that this uses UTC, not local time.
- Under "Build", choose to add a build step and select "Execute Shell". I like to use a shell script like the following:

    rm -rf build ||:
	mkdir build
	cd build
	cmake -c ..
	make
	
This removes the previous night's build directory (the "||:" ensures it doesn't throw an error if the build directory doesn't already exist), sets up a new build directory, creates a makefile assuming NO parameters, then builds.

If you wish to add parameters to your build, you would add it to the cmake line, for example "cmake -c .. -Dbuild_parameter=TRUE -Dbuild_input_string=myString"

Connecting Jenkins to CDash
---------------------------

For Jenkins to work well with CDash, I like to use a config file module. This lets me create a fairly modular system, so different projects, environments, and build types can easily pick and choose the needed config files.

Go to Jenkins home, and click "Manage Jenkins" on the lefthand toolbar, then click "Manage Plugins" on the menu that appears. Search for "Config File Provider Plugin" in the list of available modules, and follow the directions to install. Files can now be created under the Manage Jenkins menu by clicking on the new "Managed files" tab. Add a new config and choose the "Custom file" option to create your own blank file.

To get a nightly build on Linux working, I created four files.

1) CTestConfig: This file tells you how to submit your cdash project.
	
	set(CTEST_DROP_METHOD "http")
    set(CTEST_DROP_SITE "open.cdash.org")
    set(CTEST_DROP_SITE_CDASH TRUE)

    include(project.cmake)
	
2) CTestPipeline: This file tells ctest how to run through the whole pipeline of configuing, building, and then submitting to cdash.

    # Get platform specific build info
    include(platform.cmake)

    # Run CTest
    ctest_start(${CTEST_BUILD_MODEL})
    ctest_configure(BUILD ${CTEST_BINARY_DIRECTORY} SOURCE ${CTEST_SOURCE_DIRECTORY}
                    OPTIONS "${OPTIONS}")
    ctest_build()
    ctest_submit()
	
3) CTestKwiverDashboard: This is a file unique to a given project (like Kwiver) that simply gives a drop location. This line can be part of CTestConfig instead of including a separate file, but the separate file helps make the system a little more modular and easy to update.

    set(CTEST_DROP_LOCATION "/submit.php?project=kwiver")
	
4) CTestKwiverLinuxNightly: This is a build specific file. This will need to be updated for each specific project. Update the set OPTIONS line to match the cmake configs you used previously (I used the example options from above).

    set(CTEST_SITE "proteus.kitware.com")
    set(CTEST_BUILD_NAME "KwiverLinuxNightly")
    set(CTEST_SOURCE_DIRECTORY "/var/jenkins_home/jobs/KwiverLinuxNightly/workspace")
    set(CTEST_BINARY_DIRECTORY "/var/jenkins_home/jobs/KwiverLinuxNightly/workspace/build")
    set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
    set(CTEST_BUILD_CONFIGURATION Release)
    set(CTEST_PROJECT_NAME Kwiver)
    set(CTEST_BUILD_MODEL "Nightly")
    set(CTEST_NIGHTLY_START_TIME "18:00:00 UTC")
    set(CTEST_USE_LAUNCHERS 1)
    set(OPTIONS "-Dbuild_parameter=TRUE -Dbuild_input_string=myString")

    set(platform Linux)
    set(ENV{CC} gcc)
    set(ENV{CXX} g++)
    set(compiler "GCC-4.9.2")
	
These files, collectively, tell ctest to run a release build on Linux that uses the version of master from 6pm UTC the night before, using gcc or g++. If you're using a different platform, make sure to update the config file.

Now we need to update the project itself. Click on the project name in Jenkins' main menu, and then choose to configure it. Under the "Build Environment" header, check "Provice Configuration files". We'll add in our four files: CTestConfig.cmake (point to CTestConfig), platform.cmake (point to CTestKwiverLinuxNightly), jenkins_dashboard.cmake (point to CTestPipeline), and project.cmake (point to CTestKwiverDashboard).

Finally, update the shell script:

    rm -rf build ||:
    /cmake-3.7.1-Linux-x86_64/bin/ctest -S jenkins_dashboard.cmake -VV
	
This works similarly to our old (pre-CDash) script, except CTest now does most of the work we had previously done manually, and then will submit the results to the chosen dashboard.

Setting up a Windows CDash Project
----------------------------------

To start up a Windows project, many of the settings will be the same as the Linux example above. However, you'll need to update the build script and create a new build specific CTest config file.

I created a file called CTestKwiverWindowsNightly, designed after the CTestKwiverLinuxNightly file. Again, this will need to be updated for your purposes and in particular the build options need to match the choice you made previously.

    set(CTEST_SITE "squornshellous.kitware.com")
    set(CTEST_BUILD_NAME "KwiverWindowsNightly")
    set(CTEST_SOURCE_DIRECTORY "C:/Jenkins/workspace/KwiverWindowsNightly")
    set(CTEST_BINARY_DIRECTORY "C:/Jenkins/workspace/KwiverWindowsNightly/build")
    set(CTEST_CMAKE_GENERATOR "Visual Studio 14 2015")
    set(CTEST_BUILD_CONFIGURATION Release)
    set(CTEST_PROJECT_NAME Kwiver)
    set(CTEST_BUILD_MODEL "Nightly")
    set(CTEST_NIGHTLY_START_TIME "18:00:00 UTC")
    set(CTEST_USE_LAUNCHERS 1)
    set(OPTIONS "-Dbuild_parameter=TRUE -Dbuild_input_string=myString")

    set(platform Windows)
    set(ENV{CC} "cl")
    set(ENV{CXX} "cl")
    set(compiler VS)
	
Now copy your Linux project (or create a new project as described in the previous two sections), with two changes. First, change the platform.cmake file to point to your new CTestKwiverWindowsNightly file instead of CTestKwiverLinuxNightly. Second, change the build script to match Windows:

    if exist build rmdir /s /q build
    "C:\Program Files (x86)\CMake\bin\ctest" -S jenkins_dashboard.cmake -VV
	
This works similarly to the Linux script, deleting the build directory (if it exists) and then starting CTest. If you've installed cmake somewhere else, make sure to update the link.

Starting an Experimental Build for Pull Requests
------------------------------------------------

If we want a build to run during new pull requests, we first need to get a new module. In the "Manage Jenkins" menu, click "Manage Plugins" and then the "Available" tab. Search for the "GitHub Pull Request Builder" module, and install it.

Create a new project. If you already have a nightly build, you can copy it--many of the parameters are going to be the same. Scroll down to the Source Code Management section, and click "Advanced" in the Repositories option. Change Refspec to 

    +refs/pull/*:refs/remotes/origin/pr/* 
	
And change Branch Specifier to 
	
	${sha1}
	
Under Build Triggers, uncheck "Build periodically" and instead check "GitHubPull Request Builder". There are two ways you can choose when the project is built. The first, easier way is to just select the "Build every pull request" checkbox in the advanced settings. This means you don't need to worry about maintenance, but can get a little dangerous because now a malicious user can run any arbitrary CMake instructions with any arbitrary file on your computer. Instead, you can update the white list or add to the admin list. Anyone on the white list will have their pull requests automatically tested. For people not on the white list, someone on the admin list can respond to the pull request with "ok to test" to build the PR, or "add to whitelist" if the PR author should be added to the white list.

You'll also need to update the CTestKwiverLinuxNightly file (or the Mac/Windows equivalents). Create a new config file copying CTestKwiverLinuxNightly, updating the parameters CTEST_BUILD_NAME, CTEST_SOURCE_DIRECTORY, and CTEST_BINARY_DIRECTORY to use the new Jenkins project's name. In addition, update the CTEST_BUILD_MODEL to "Experimental" and get rid of the CTEST_NIGHTLY_START_TIME. You can now update the new project to use this new file for its platform.cmake.

Adding a Remote Windows Slave
-----------------------------

If you want to run tasks on a remote Windows machine, you need to create a new slave node. Go into the Manage Jenkins menu and select "Manage Nodes". Add a new node and choose a name.

First, choose a number of executors. That's the number of tasks that can be run concurrently. If you're planning on light usage, you might want to just leave it at one--that way, different builds won't get in each other's way. If you want to do more, just be careful that you write your build script in such a way that different runs won't get in each other's way.

Select a remote root directory. For Windows, I stick with something like "C:/Jenkins" to keep the directory obvious, but you may want to put it somewhere else for your own purposes.

Create a label. I stick with something like the particular Windows version or the visual studio version being used, for example "Windows2015". This is what allows you to determine which tasks run on which machine.

Switch usage to "Only build jobs with label expressions matching this node." This ensures that you won't build the wrong task on the wrong slave.

Keep Launch Method at "Launch Agent via Java Web Start". This is the most reliable way on Windows.

Set Availability to your preference. I usually "Keep the agent online as much as possible" but you may need another setting for your purposes.

After you save, you'll have a list of agents. Click on your new agent, and you'll see two options for start: you can launch from browser or download a slave.jar file and run a given command on the command line. You can use either, but for maximum uptime I recommend downloading the slave.jar and creating a Windows task that will run the command on startup.

You should now be connected to your Windows slave. To assign a task to it, click on the project name from Jenkins' main menu and then choose "Configure". Choose the "Restrict where this project can be run" option and then fill in the label corresponding to your new slave.

Adding a Remote Linux or Mac Slave
----------------------------------

If you want to run tasks on a remote Linux or Mac machine, you need to create a new slave node. Go into the Manage Jenkins menu and select "Manage Nodes". Add a new node and choose a name.

First, choose a number of executors. That's the number of tasks that can be run concurrently. If you're planning on light usage, you might want to just leave it at one--that way, different builds won't get in each other's way. If you want to do more, just be careful that you write your build script in such a way that different runs won't get in each other's way.

Select a remote root directory. For Linux, I stick with something like "/var/jenkins_home", the recommended volume used by the Jenkins docker, but you may want to put it somewhere else for your own purposes.

Create a label. I stick with something like the kernel or operating system, for example "Linux" or more specifically "Ubuntu" if I'm planning on having multiple Linux slaves. This is what allows you to determine which tasks run on which machine.

Switch usage to "Only build jobs with label expressions matching this node." This ensures that you won't build the wrong task on the wrong slave.

Change Launch Method to "Launch slave agents via SSH". Select the host name of the slave and fill in credentials if necessary. SSH works well with Linux, because it allows Jenkins and the slave to contact each other if and only if it's necessary, rather than relying on a constant connection like Windows requires.

Set Availability to your preference. I usually "Keep the agent online as much as possible" but you may need another setting for your purposes.

Unlike Windows slaves, relying on SSH means Jenkins can connect on its own. As long as the slave will accept SSH connections, you don't need to run anything else on the slave. So there's no need to do any other configuration that needs to be done, or new processes to run on the slave, Jenkins should immediately connect.

To assign a task to the slave, click on the project name from Jenkins' main menu and then choose "Configure". Choose the "Restrict where this project can be run" option and then fill in the label corresponding to your new slave.
