namespace OrderService.Messaging;

public interface IMessagePublisher
{
    void PublishOrderMessage(object orderMessage);
}

