// BooksApp, (c) 2007 by Zachary Brewster-Geisz

/*
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; version 2
 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 
 */

#import "UIOrientingApplication.h"

@class UIWindow;
@class UIApplication;
@class UIView;
@class UITextView;
@class UITransitionView;
@class UINavBarButton;
@class UIProgressHUD;

@class HideableNavBar;
@class FileBrowser;
@class EBookView;
@class EBookImageView;
@class BooksDefaultsController;
@class FileNavigationItem;

enum PreferenceAnimationType;
@class PreferencesController;

@interface BooksApp : UIOrientingApplication {
	UIWindow 	*window;
	UIView      *mainView;
	HideableNavBar  *navBar, *bottomNavBar;
  UITransitionView *m_transitionView;
  EBookImageView *m_startupImage;
  
  UIProgressHUD *m_progressIndicator;
  
	NSString    *path;
  
	BOOL        bookHasChapters;
	BOOL        readingText;
	BOOL        textInverted;
	BOOL        rotate90;
  
	BooksDefaultsController *defaults;
	UINavBarButton *minusButton;
	UINavBarButton *plusButton;
	UINavBarButton *invertButton;
	UINavBarButton *rotateButton;
	UINavBarButton *prefsButton;
	UINavBarButton *downButton;
	UINavBarButton *upButton;
	UINavBarButton *rightButton;
	UINavBarButton *leftButton;
  
	NSString *imgPath;
  NSArray *m_documentExtensions;

	/** 
	 * If NO, a permissions error should quit, not return 
	 * to the file browser.
	 */
	BOOL m_openedFirstDoc;
    float                    initVol;
    float                    curVol;
    bool                     volChanged;

}

- (void)clearVolumeChanged:(id)unused;
- (void) volumeChanged:(NSNotification *)notify;
+ (void)debugNotification:(NSNotification*)p_note;
- (void)showPleaseWait;
- (void)hidePleaseWait;
- (UIView*)showDocumentAtPath:(NSString*)p_path;
- (void)fileBrowser: (FileBrowser *)browser fileSelected:(NSString *)file;
- (void)setNavForItem:(FileNavigationItem*)p_item;
- (void)showNavbars;
- (void)hideNavbars;
- (void)embiggenText:(UINavBarButton *)button;
- (void)ensmallenText:(UINavBarButton *)button;
- (void)invertText:(UINavBarButton *)button;
- (void)setTextInverted:(BOOL)b;
- (void)setupNavbar;
- (void)setupToolbar;
- (void)updateToolbar:(NSNotification *)notification;
- (UINavBarButton *)toolbarButtonWithName:(NSString *)name rect:(struct CGRect)rect selector:(SEL)selector flipped:(BOOL)flipped;
- (UIImage *)navBarImage:(NSString *)name flipped:(BOOL)flipped;
- (void)showPrefs:(UINavBarButton *)button;
- (UIWindow *)appsMainWindow;
- (void)adjustStatusBarColorWithUiOrientation:(int)p_orientation;
- (NSString *)currentBrowserPath;
- (void)cleanUpBeforeQuit;
- (void)cleanupStartupImage;
- (void)rotateButtonCallback:(UINavBarButton*) button;
- (void)applicationDidFinishLaunching: (id) unused;
- (void)finishUpLaunch;
- (void) preferenceAnimationDidFinish;
- (void)alertSheet:(UIAlertSheet *)sheet buttonClicked:(int)button ;

- (void)chapBack:(UINavBarButton *)button;
- (void)chapForward:(UINavBarButton *)button;
- (void)showTopNav;
@end
