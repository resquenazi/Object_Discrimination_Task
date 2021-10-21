# Object_Discrimination_Task
###### This code was written for an experiment that simulates the abnormal on- and off-cell population responses elicited by electronic sight recovery technologies
###### code written by Rebecca Esquenazi with supervision by Ione Fine in Matlab

## About
Many forms of artificial sight recovery, such as electronic implants and optogenetic proteins, generally cause simultaneous, rather than complementary firing of on- and off-center retinal cells. Here, using ‘virtual patients’ – sighted individuals viewing distorted input – we examine whether plasticity might compensate for abnormal neuronal population responses. Five participants were dichoptically presented with a combination of original and contrast-reversed images. Each image (I) and its contrast-reverse (I’) was filtered using a radial checkerboard (F) in Fourier space and its inverse (F’). [I * F′] + [I’* F] was presented to one eye, while [I * F] + [I’ * F′] was presented to the other, such that regions of the image that produced on-center responses in one eye produced off-center responses in the other eye, and vice versa. Participants continuously improved in a naturalistic object discrimination task over 20 one-hour sessions. Pre- and post-training tests suggest that performance improvements were due to two learning processes: learning to recognize objects with reduced visual information, and learning to suppress contrast-reversed image information in a non-eye-selective manner. These results suggest that, with training, it may be possible to adapt to the unnatural on- and off-cell population responses produced by electronic and optogenetic sight recovery technologies.

The aim of the current study was to produce abnormal population responses within V1 that serve as a rough proxy to the abnormal population responses elicited by electronic sight restoration technologies. Five participants were trained in an object discrimination task (described below) using a dichoptic (a different image to each eye) presentation. Images were convolved with filters via multiplication in the Fourier domain. Our filter, F was defined as a radial checkerboard in Fourier space such that, when convolved with an image, I, only half of the total combination of spatial frequencies and orientations in I were passed through. Convolving with the filter’s inverse (F’) passed the other half of the spatial frequencies and orientations in I. Images and filters were combined such that [I * F′] + [I’* F] was presented to one eye, and [I * F] + [I’ * F′] to the other (where * denotes 2D convolution). Thus, regions of the resulting image that produced on-cell responses in one eye produced off-cell responses in the other eye at the corresponding visual location, and vice versa.

## Task
All of the tasks (pre-test, training, and post-test) are the same, with slightly different conditions. In each trial, there is a 50% chance that the scene contained the prompted object, or a different distractor object. Auditory feedback is provided after each trial to indicate whether the answer is correct or incorrect. Participants are not given specific instructions on where to look within the scene.

A brief fixation cue (0.5 s) began each trial. After a 0.5 s pause, a word cue told the participants what the target object was (e.g. “cup”, “clock”). Following the word cue, a scene with an overlaid object is displayed for up to 2s, or until the participant responds with a key press. To create a dynamic scene that more closely resembles naturalistic retinal input, and to encourage generalizable learning by creating more variation in the retinal image, there is a simulated ‘panning action’ within each 2s trial. The field of view drifts to the right or left, at a rate that is uniformly distributed between 0.21 and 0.52 degrees/s. The image also expanded or contracted at a maximum rate of 0.35 degrees/s. The task is performed using a custom built stereoscope.

### **ObjectDiscriminationPre_Test.m & ObjectDsicrimination_PostTest.m**
Each of these tasks are exactly the same, however results are automaticaly saved to different directories. The conditions below describe each pre-test. It is likely that participants may use a combination of strategies to decode the images. These tests monitor performance on the object recognition task before and after training, to assess how training affected learning. 

#### ***Monocular Presentation***
Participants are shown the filtered image to the left or right eye only (randomly interleaved across trials).

#### ***Filter-switched***
Left and right eye filters were switched across the two eyes, such that the eye trained to view [I * F′] + [I’ * F] received [I * F] + [I’ * F′], and vice versa.

#### ***1/f Noise***
The contrast-reversed image I’ was replaced by a 1/f noise pattern, such that the eye trained to view [I * F′] + [I’ * F] received [I * F′] + [1/f * F], and the eye trained to view [I * F] + [I’ * F′] received [I * F] + [1/f * F’].


### **Object_Discrmimination_Training.m**
This is the main task used in the training phase of the study. 
