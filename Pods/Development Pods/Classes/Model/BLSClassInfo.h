#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, BLSEncodingType) {
    BLSEncodingTypeMask       = 0xFF, ///< mask of type value
    BLSEncodingTypeUnknown    = 0, ///< unknown
    BLSEncodingTypeVoid       = 1, ///< void
    BLSEncodingTypeBool       = 2, ///< bool
    BLSEncodingTypeInt8       = 3, ///< char / BOOL
    BLSEncodingTypeUInt8      = 4, ///< unsigned char
    BLSEncodingTypeInt16      = 5, ///< short
    BLSEncodingTypeUInt16     = 6, ///< unsigned short
    BLSEncodingTypeInt32      = 7, ///< int
    BLSEncodingTypeUInt32     = 8, ///< unsigned int
    BLSEncodingTypeInt64      = 9, ///< long long
    BLSEncodingTypeUInt64     = 10, ///< unsigned long long
    BLSEncodingTypeFloat      = 11, ///< float
    BLSEncodingTypeDouble     = 12, ///< double
    BLSEncodingTypeLongDouble = 13, ///< long double
    BLSEncodingTypeObject     = 14, ///< id
    BLSEncodingTypeClass      = 15, ///< Class
    BLSEncodingTypeSEL        = 16, ///< SEL
    BLSEncodingTypeBlock      = 17, ///< block
    BLSEncodingTypePointer    = 18, ///< void*
    BLSEncodingTypeStruct     = 19, ///< struct
    BLSEncodingTypeUnion      = 20, ///< union
    BLSEncodingTypeCString    = 21, ///< char*
    BLSEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    BLSEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    BLSEncodingTypeQualifierConst  = 1 << 8,  ///< const
    BLSEncodingTypeQualifierIn     = 1 << 9,  ///< in
    BLSEncodingTypeQualifierInout  = 1 << 10, ///< inout
    BLSEncodingTypeQualifierOut    = 1 << 11, ///< out
    BLSEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    BLSEncodingTypeQualifierByref  = 1 << 13, ///< byref
    BLSEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    BLSEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    BLSEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    BLSEncodingTypePropertyCopy         = 1 << 17, ///< copy
    BLSEncodingTypePropertyRetain       = 1 << 18, ///< retain
    BLSEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    BLSEncodingTypePropertyWeak         = 1 << 20, ///< weak
    BLSEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    BLSEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    BLSEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/**
 Get the type from a Type-Encoding string.
 
 @discussion See also:
 
 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */
BLSEncodingType BLSEncodingGetType(const char *typeEncoding);


/**
 Instance variable information.
 */
@interface BLSClassIvarInfo : NSObject
@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) BLSEncodingType type;    ///< Ivar's type

/**
 Creates and returns an ivar info object.
 
 @param ivar ivar opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithIvar:(Ivar)ivar;
@end


/**
 Method information.
 */
@interface BLSClassMethodInfo : NSObject
@property (nonatomic, assign, readonly) Method method;                  ///< method opaque struct
@property (nonatomic, strong, readonly) NSString *name;                 ///< method name
@property (nonatomic, assign, readonly) SEL sel;                        ///< method's selector
@property (nonatomic, assign, readonly) IMP imp;                        ///< method's implementation
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< method's parameter and return types
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< array of arguments' type

/**
 Creates and returns a method info object.
 
 @param method method opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithMethod:(Method)method;
@end


/**
 Property information.
 */
@interface BLSClassPropertyInfo : NSObject
@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) BLSEncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 Creates and returns a property info object.
 
 @param property property opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithProperty:(objc_property_t)property;
@end


/**
 Class information for a class.
 */
@interface BLSClassInfo : NSObject
@property (nonatomic, assign, readonly) Class cls; ///< class object
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nullable, nonatomic, strong, readonly) BLSClassInfo *superClassInfo; ///< super class's class info
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, BLSClassIvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, BLSClassMethodInfo *> *methodInfos; ///< methods
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, BLSClassPropertyInfo *> *propertyInfos; ///< properties

/**
 If the class is changed (for example: you add a method to this class with
 'class_addMethod()'), you should call this method to refresh the class info cache.
 
 After called this method, `needUpdate` will returns `YES`, and you should call 
 'classInfoWithClass' or 'classInfoWithClassName' to get the updated class info.
 */
- (void)setNeedUpdate;

/**
 If this method returns `YES`, you should stop using this instance and call
 `classInfoWithClass` or `classInfoWithClassName` to get the updated class info.
 
 @return Whether this class info need update.
 */
- (BOOL)needUpdate;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param cls A class.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param className A class name.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
