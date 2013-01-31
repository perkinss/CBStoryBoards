//
//  constants.h
//  CoastBuster
//
//  Created by Jeff Proctor on 2012-10-16.
//

#ifndef CoastBuster_constants_h
#define CoastBuster_constants_h

#define APP_TITLE           @"Coastbuster"
#define PLIST_FILENAME      @"photos.plist"
#define DISCLAIMER_FILENAME @"disclaimer"
#define INFO_FILENAME       @"help"

#define USER_ID_URL         @"http://dmas.uvic.ca/CoastBusterIDService"
#define FTP_URL             @"ftp://ncftp.neptune.uvic.ca/beachcomber/images"
#define FTP_USERNAME        @"beachcomber"
#define FTP_PASSWORD        @"deZ6cHeS"
#define FTP_TIMEOUT_SECONDS 60


#define TIME_ZONE_UTC       @"UTC"
#define TIME_FORMAT_NEPTUNE @"yyyyMMdd'T'HHmmss.SSS'Z'"
#define TIME_FORMAT_EXIF    @"yyyy:MM:dd HH:mm:ss"


#define MAX_GPS_UNCERTAINTY 150      // in meters
#define MAX_SECONDS_ELAPSED_FOR_LOCATION    15
#define FIND_LOCATION_TIMEOUT               15
#define FIND_LOCATION_TITLE                 @"Finding location..."
#define LOCATION_SERVICES_UNAVAILABLE_MESSAGE       @"Location services are not available.  Please enable location services under Settings"
#define CANNOT_FIND_LOCATION_MESSAGE                @"Unable to determine your location"
#define CAMERA_UNAVAILABLE_MESSAGE                  @"Camera not available on this device"


#define IMAGE_FILE_KEY      @"imageFile"
#define THUMB_FILE_KEY      @"thumbnail"

#define COMMENT_KEY         @"comment"
#define CATEGORY_KEY        @"category"
#define COMPOSITION_KEY     @"composition"

#define LATITUDE_KEY        @"latitude"
#define LONGITUDE_KEY       @"longitude"
#define TIMESTAMP_KEY       @"timestamp"

#define WIDTH_KEY           @"width"
#define LENGTH_KEY          @"length"
#define FROM_JAPAN_KEY      @"fromjapan"
#define HAZARDOUS_KEY       @"hazardous"
#define STATUS_KEY          @"status"
#define CREATURE_KEY        @"creature"



#define CATEGORIES          @"Other/unknown", @"Aerosol cans", @"Bags", @"Balloons", @"Bottles", @"Building materials", @"Buoys/floats", @"Cans", @"Cartons", @"Cigarettes", @"Cigarette lighters", @"Clothing/shoes", @"Containers/jars/jugs", @"Cups", @"Fishing lines/lures", @"Food wrappers", @"Gloves", @"Household items", @"Human remains", @"Marine equipment/fishing gear", @"Packaging materials", @"Personal care products", @"Ropes/nets", @"6-pack rings", @"Tires", @"Towels/rags", @"Utensils/straws"
#define COMPOSITIONS        @"Other/unknown", @"Cardboard/paper", @"Fabric", @"Glass", @"Metal", @"Mixture", @"Plastic/foam", @"Rubber", @"Wood"
#define FROM_JAPAN_OPTIONS  @"Yes", @"No", @"Unsure"
#define HAZARDOUS_OPTIONS   @"Yes", @"No", @"Unsure"
#define STATUS_OPTIONS      @"Buried/partially buried", @"Floating", @"Stranded above high tide line", @"Stranded below high tide line", @"Sunken", @"Other"
#define CREATURE_OPTIONS    @"Yes", @"No", @"Unsure"

#define PHOTO_KEY           @"photos"
#define PHOTO_NUM_KEY       @"photoNumber"
#define USER_ID_KEY         @"userID"
#define TERMS_AGREED_KEY    @"agreedToTerms"

#define BUTTON_TEXT_CAMERA  @"Take a debris photo"
#define BUTTON_TEXT_ABOUT   @"Help / About"
#define BUTTON_TEXT_GALLERY @"View and upload images"

#define PENDING_ID_STRING   @"pending"


#define NAVBAR_HEIGHT_PORTRAIT      44
#define NAVBAR_HEIGHT_LANDSCAPE     32
#define STATUS_BAR_HEIGHT           20
#define SUPPORTED_ORIENTATION       UIInterfaceOrientationMaskAll

#define TABLE_VIEW_SELECT_COLOR     [UIColor colorWithRed:88.0f/256.0f green:199.0f/256.0f blue:252.0f/256.0f alpha:1.0f]
#define USER_ID_LABEL_COLOR         [UIColor colorWithRed:88.0f/256.0f green:199.0f/256.0f blue:252.0f/256.0f alpha:1.0f]


#define COMMENT_LABEL           @"Comment (optional):"
#define COMMENT_PLACEHOLDER     @"Enter other details ... "
#define COMPOSITION_LABEL       @"Composition:"
#define COMPOSITION_PLACEHOLDER @"What is it made of? ..."
#define CATEGORY_LABEL          @"Category:"
#define CATEGORY_PLACEHOLDER    @"Select a category ..."
#define MORE_INFO_LABEL         @"More info (optional):"
#define WIDTH_LABEL             @"Approximate width (cm):"
#define LENGTH_LABEL            @"Approximate length (cm):"
#define FROM_JAPAN_LABEL        @"Does the object have any identifying Japanese words or numbers?"
#define FROM_JAPAN_NOTE         @"(If yes or unsure, please send an additional close-up photo.)"
#define HAZARDOUS_LABEL         @"Is the object possibly hazardous?"
#define HAZARDOUS_NOTE          @"(Examples: oil/chemical drum, gas can, propane tank. If yes, do not touch and report to local authorities.)"
#define STATUS_LABEL            @"What is its status?"
#define CREATURE_LABEL          @"Does it have marine organisms growing on it?"
#define CREATURE_NOTE           @"(If yes, please try to safely move it above the high-tide line and send us a close-up photo.)"


#endif
