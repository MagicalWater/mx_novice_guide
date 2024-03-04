## 1.0.4+2
- MxNoviceGuide
  * Added variables autoStart: whether to automatically start the first step
  * Added variables autoStartDelay: delay time for automatic start

## 1.0.3+1
- Fixed that when the FocusAnimationType of the two steps are different, the transition animation is not smooth when switching between each other

## 1.0.2+1
- Optimize the display of desc, add an animation interpolator to make the transition softer

- Add three new parameters
  * animationDuration - execute focus animation time
  * animationType - focus animation type
  * animationCurve - focus animation curve

## 1.0.1+1
- MxNoviceGuide.next() and MxNoviceGuide.previous() methods add parameters
  * waitCurrentEnd /// wait for the current step to end focus
  * currentEndWithAnimation /// is current step end focus with animation
  * onCurrentEndComplete /// current step end focus complete callback

- Optimize focus animation

## 1.0.0
- init version
