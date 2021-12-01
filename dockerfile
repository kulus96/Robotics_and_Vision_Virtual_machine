FROM ros:melodic-ros-base


ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Setting timezone 
ENV TZ=Europe/Copenhagen
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Opencv 3
COPY ./opencv_install.sh /
RUN sh -e /opencv_install.sh 

RUN apt update 

# Setup user 
RUN useradd -m user -p "$(openssl passwd -1 user)"
RUN usermod -aG sudo user 


COPY ./root /home/user


# Extra
RUN apt update && apt install -y nano \
                                 vim \
                                 ssh \
                                 openssh* \
                                 sudo \
                                 gdb \
               && rm -rf /var/lib/apt/lists/*



# Setting python
RUN rm /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python 

RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
RUN mkdir /var/run/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN apt update
RUN apt install iputils-ping

RUN apt-get install software-properties-common -y # used to install rtde

# packages needed to run ROS melodic with python2.7
RUN apt install python2.7
RUN apt-get install -y python-pip 
RUN apt-get install -y python3-pip 
RUN pip install catkin_pkg
RUN pip install rospkg
RUN pip install netifaces
RUN pip install rosdep
RUN pip install defusedxml
RUN pip install scipy
RUN pip install --upgrade pip
RUN rosdep update 

RUN apt-get install libopencv-dev -y
RUN apt-get update
RUN apt-get install ros-melodic-cv-bridge -y
RUN apt-get install ros-melodic-image-transport-plugins -y
RUN apt-get install ros-melodic-openni2-launch   -y


RUN add-apt-repository ppa:sdurobotics/ur-rtde
RUN apt-get update
RUN apt install librtde librtde-dev
RUN apt-get update
RUN pip install ur-rtde

RUN apt install nlohmann-json-dev

#RUN rosdep init 

# Setting user and the workdir
USER user
RUN mkdir /home/user/workspace
RUN mkdir /home/user/workspace/src
WORKDIR /home/user/workspace




