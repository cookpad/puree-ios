#import "PURLog.h"

@implementation PURLog

- (instancetype)initWithTag:(NSString *)tag date:(NSDate *)date userInfo:(nonnull NSDictionary<NSString *,id> *)userInfo
{
    self = [super init];
    _identifier = [NSUUID UUID].UUIDString;
    _tag = tag;
    _date = date;
    _userInfo = userInfo;

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _tag = [aDecoder decodeObjectForKey:@"tag"];
        _date = [aDecoder decodeObjectForKey:@"date"];
        _userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.tag forKey:@"tag"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
}

@end
