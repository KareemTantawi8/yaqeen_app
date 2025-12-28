# Testing Guide for Yaqeen App Restructuring

## Quick Testing Checklist

### 1. Build Test
```bash
cd /Users/kareemmahmoud/Projects/yaqeen_app
flutter clean
flutter pub get
flutter build ios --debug
# OR
flutter build apk --debug
```

### 2. Manual Testing Steps

#### A. Prayer Tab Testing
1. Open app and navigate to Prayer tab (الصلاة)
2. Verify prayer times display correctly
3. Verify next prayer countdown is working
4. Check/uncheck prayer completion boxes
5. Verify checkmarks persist after app restart
6. Check prayer statistics display
7. Tap "القبلة" button and verify Qibla screen opens
8. Tap "الأذان" button and verify Adhan screen opens
9. Tap "المسبحة" button and verify Mespha screen opens
10. Pull to refresh and verify data updates

**Expected Result**: All features work without errors

#### B. Home Tab Testing
1. Navigate to Home tab (الرئيسية)
2. Verify welcome message displays
3. Verify Hijri date displays correctly
4. Verify Islamic Events widget shows
5. Verify Daily Ayah displays
6. Verify Today's Stats show (prayer completion)
7. Verify Daily Hadith displays
8. Verify Recent Quran reading widget shows
9. Pull to refresh and verify updates
10. Tap Islamic Events widget and verify Events screen opens

**Expected Result**: Dashboard displays all content cleanly

#### C. Azkar Tab Testing
1. Navigate to Azkar tab (الأذكار)
2. Verify Azkar categories display
3. Tap any category and verify detail screen opens
4. Verify counter works for dhikr
5. Pull to refresh and verify updates

**Expected Result**: Azkar feature works as before

#### D. Quran Tab Testing
1. Navigate to Quran tab (القرآن)
2. Verify Surah list displays
3. Verify recent reading card shows
4. Tap "المصحف الكامل" and verify full Mushaf opens
5. Tap "قراءة سورة كاملة" and verify audio screen opens
6. Tap any Surah and verify it opens
7. Verify tabs (قراءة السورة / تشغيل السور) work

**Expected Result**: All Quran features work properly

#### E. Settings/More Tab Testing
1. Navigate to More tab (المزيد)
2. Verify all sections display:
   - المحتوى الإسلامي (Islamic Content)
   - الوسائط (Media)
   - إعدادات التطبيق (Settings)
   - عن التطبيق (About)
3. Tap "الأحاديث" and verify Hadith screen opens
4. Tap "أسماء الله" and verify Names screen opens
5. Tap "كتب إسلامية" and verify Books screen opens
6. Tap "المناسبات" and verify Events screen opens
7. Tap "الراديو" and verify Radio screen opens
8. Tap "أسأل يقين" and verify "Coming Soon" message shows
9. Tap "الوضع المظلم" and verify "Coming Soon" message shows
10. Tap "مشاركة التطبيق" and verify share dialog opens
11. Tap "عن يقين" and verify about dialog opens

**Expected Result**: All navigation works, placeholders show appropriate messages

#### F. Bottom Navigation Testing
1. Tap each tab in bottom navigation
2. Verify correct screen displays for each tab
3. Verify selected tab is highlighted
4. Verify labels are correct:
   - الأذكار (Azkar)
   - الصلاة (Prayer)
   - الرئيسية (Home)
   - القرآن (Quran)
   - المزيد (More)
5. Verify icons are appropriate

**Expected Result**: All tabs accessible and working

### 3. Data Persistence Testing

#### Prayer Completion:
1. Open Prayer tab
2. Check off 2-3 prayers
3. Force close the app
4. Reopen the app
5. Navigate to Prayer tab
6. Verify checked prayers are still checked

**Expected Result**: Data persists

#### Quran Reading:
1. Read any Surah in Quran tab
2. Close the app
3. Reopen the app
4. Navigate to Home or Quran tab
5. Verify "Recent Quran Read" shows last read position

**Expected Result**: Last read position is saved

### 4. Error Handling Testing

#### No Internet:
1. Turn off internet/WiFi
2. Open app
3. Pull to refresh on various screens
4. Verify appropriate error messages show
5. Verify "إعادة المحاولة" (Retry) button works

**Expected Result**: Graceful error handling

#### No Location Permission:
1. Deny location permission
2. Open app
3. Verify fallback location is used
4. Verify prayer times still display

**Expected Result**: App works with fallback

### 5. UI/UX Testing

#### Visual Testing:
- [ ] All text is readable
- [ ] Colors are consistent
- [ ] Spacing is appropriate
- [ ] No UI overflow errors
- [ ] Images load correctly
- [ ] Icons display correctly
- [ ] Gradients render smoothly
- [ ] Shadows are subtle
- [ ] Borders are visible

#### Arabic/RTL Testing:
- [ ] All text is right-aligned
- [ ] Icons are on correct side
- [ ] Navigation flows right-to-left
- [ ] Numbers display correctly
- [ ] Arabic fonts render properly

#### Responsiveness:
- [ ] Test on different screen sizes
- [ ] Test in portrait mode
- [ ] Test in landscape mode
- [ ] Test on tablet (if applicable)

### 6. Performance Testing

#### Load Times:
- [ ] App launches within 3 seconds
- [ ] Tab switching is instant
- [ ] Data loads within 2 seconds
- [ ] Images load smoothly
- [ ] No lag when scrolling

#### Memory:
- [ ] Monitor memory usage
- [ ] Check for memory leaks
- [ ] Verify app doesn't crash

#### Battery:
- [ ] Monitor battery usage
- [ ] Ensure no excessive drain

---

## Common Issues & Solutions

### Issue 1: Import Errors
**Solution**: Run `flutter pub get` to install dependencies

### Issue 2: Build Fails
**Solution**: 
```bash
flutter clean
flutter pub get
flutter run
```

### Issue 3: Prayer Times Not Loading
**Solution**: Check location permissions and internet connection

### Issue 4: Data Not Persisting
**Solution**: Check SharedPreferences implementation

### Issue 5: UI Overflow
**Solution**: Test on actual device, not just simulator

---

## Test Results Template

### Test Date: _____________
### Tester: _____________
### Device: _____________
### OS Version: _____________

| Feature | Status | Notes |
|---------|--------|-------|
| Prayer Tab | ⬜ Pass ⬜ Fail | |
| Home Tab | ⬜ Pass ⬜ Fail | |
| Azkar Tab | ⬜ Pass ⬜ Fail | |
| Quran Tab | ⬜ Pass ⬜ Fail | |
| More Tab | ⬜ Pass ⬜ Fail | |
| Bottom Nav | ⬜ Pass ⬜ Fail | |
| Data Persistence | ⬜ Pass ⬜ Fail | |
| Error Handling | ⬜ Pass ⬜ Fail | |
| UI/UX | ⬜ Pass ⬜ Fail | |
| Performance | ⬜ Pass ⬜ Fail | |

### Overall Result: ⬜ Pass ⬜ Fail

### Critical Issues Found:
1. 
2. 
3. 

### Minor Issues Found:
1. 
2. 
3. 

### Recommendations:
1. 
2. 
3. 

---

**Testing Status**: Ready for QA ✅

